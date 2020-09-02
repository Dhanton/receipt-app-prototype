from rest_framework import serializers
from .models import User, Receipt, ReceiptItem

class UserSerializer(serializers.ModelSerializer):
    # receipts = serializers.PrimaryKeyRelatedField(many=True, queryset=Receipt.objects.all())
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'password']

    def create(self, validated_data):
        user = super(UserSerializer, self).create(validated_data)
        user.set_password(validated_data['password'])
        user.save()
        return user

class ReceiptItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReceiptItem
        fields = ['name', 'quantity', 'price']

class ReceiptSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    shop = serializers.ReadOnlyField(source='shop.name')

    items = ReceiptItemSerializer(many=True)

    class Meta:
        model = Receipt
        fields = ['shop', 'creation_date', 'expiration_date', 'is_returnable', 'items', 'owner']

    #Recursively print all items of this Receipt
    def get_fields(self):
        fields = super(ReceiptSerializer, self).get_fields()
        fields['items'] = ReceiptItemSerializer(many=True)
        return fields

    def create(self, validated_data):
        items = validated_data.pop('items')
        receipt = Receipt.objects.create(**validated_data)

        for item in items:
            ReceiptItem.objects.create(receipt=receipt, **item)

        return receipt
