from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings

class User(AbstractUser):
    is_shop_manager = models.BooleanField(default=False)

    def __str__(self):
        return self.username

class Shop(models.Model):
    name = models.CharField(max_length=200, unique=True)
    website = models.URLField(default='')
    managers = models.ManyToManyField(settings.AUTH_USER_MODEL)

    def __str__(self):
        return self.name

class Receipt(models.Model):
    owner = models.ForeignKey(User, related_name='receipts', on_delete=models.CASCADE)
    shop = models.ForeignKey(Shop, on_delete=models.CASCADE)

    creation_date = models.DateTimeField()
    expiration_date = models.DateTimeField(auto_now_add=True, blank=True)
    is_returnable = models.BooleanField(default=False)

    def __str__(self):
        return 'Shop:' + str(self.shop) + ';Owner:'+ str(self.owner) + ';Date:' + str(self.creation_date)

class ReceiptItem(models.Model):
    receipt = models.ForeignKey(Receipt, related_name='items', on_delete=models.CASCADE)

    name = models.CharField(max_length=50)
    quantity = models.IntegerField(default=1)
    price = models.FloatField()

    def __str__(self):
        return self.name + '  x' + str(self.quantity) + '  ' + str(self.price)
