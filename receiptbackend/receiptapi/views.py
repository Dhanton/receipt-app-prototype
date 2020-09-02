import uuid, json
from django.core.cache import caches

from rest_framework import generics
from rest_framework import permissions, authentication
from rest_framework.decorators import api_view, authentication_classes
from rest_framework.response import Response

from .models import Receipt, User, Shop
from .serializers import ReceiptSerializer, UserSerializer
from .permissions import IsOwner

class ReceiptsList(generics.ListAPIView):
    # queryset = Receipt.objects.all()
    serializer_class = ReceiptSerializer

    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [IsOwner]

    #Return all receipts owned by the current user (emtpy if no user authenticated)
    def get_queryset(self):
        if self.request.user.is_authenticated:
            return Receipt.objects.filter(owner=self.request.user)
        else:
            return Receipt.objects.none()

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

class CreateAccount(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = (permissions.AllowAny,)

#probably should use a dict instead, whatever
class CacheData:
    def __init__(self, serializer, shop_id):
        self.serializer = serializer
        self.shop_id = shop_id

@api_view(['GET'])
@authentication_classes([authentication.TokenAuthentication])
def verify_auth_token(request):
    data = {}

    if not request.user.is_authenticated:
        data['authenticated'] = 0
    else:
        data['authenticated'] = 1
        data['is_shop_manager'] = request.user.is_shop_manager

    return Response(data)


@api_view(['POST'])
@authentication_classes([authentication.TokenAuthentication])
def generate_receipt(request):
    if not request.user.is_authenticated:
        return Response(data='generate-receipt error: User must be authenticated.', status=401)

    if not request.user.is_shop_manager:
        return Response(data='generate-receipt error: Only shop managers can generate receipts.', status=403)

    try:
        json_data = json.loads(request.body.decode("utf-8"))
    except ValueError:
        return Response(data='generate-receipt error: Invalid json syntax.', status=400)

    if not 'shop' in json_data or Shop.objects.filter(name=json_data['shop']).count() != 1:
        return Response(data='generate-receipt error: Incorrect or missing shop data.', status=400)

    receipt_serializer = ReceiptSerializer(data=json_data)

    if not receipt_serializer.is_valid():
        return Response(data=receipt_serializer.errors, status=400)

    cache = caches['receipt_generation']
    auth_hash = uuid.uuid4().hex

    #After 30 seconds the hash expires
    cache.set(auth_hash, CacheData(receipt_serializer, Shop.objects.get(name=json_data['shop']).id), 30)
    
    #TODO: Also send hash expiration time as json
    return Response(auth_hash)

@api_view(['POST'])
@authentication_classes([authentication.TokenAuthentication])
def verify_receipt(request):
    if not request.user.is_authenticated:
        return Response(data='verify-receipt error: User must be authenticated.', status=401)

    auth_hash = request.body.decode('utf-8')
    cache = caches['receipt_generation']

    if cache.get(auth_hash) is None:
        return Response(data='verify-receipt error: Incorrect receipt hash.', status=400)

    receipt_serializer = cache.get(auth_hash).serializer
    shop_id = cache.get(auth_hash).shop_id

    if not receipt_serializer.is_valid():
        return Response(data='verify-receipt error: Internal serializer error.', status=400)

    shop = Shop.objects.get(pk=shop_id)

    if shop is None:
        return Response(data='verify-receipt error: Internal shop cache error.', status=404)

    receipt_serializer.save(owner=request.user, shop=shop)
    cache.delete(auth_hash)

    return Response(receipt_serializer.data)
