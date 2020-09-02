from django.urls import path
from rest_framework.authtoken import views

from .views import ReceiptsList, CreateAccount, generate_receipt, verify_receipt, verify_auth_token

urlpatterns = [
    path('auth-token/', views.obtain_auth_token),
    path('verify-auth-token/', verify_auth_token),
    path('create-account/', CreateAccount.as_view()),

    path('receipts/', ReceiptsList.as_view()),
    path('generate-receipt/', generate_receipt),
    path('verify-receipt/', verify_receipt),
]
