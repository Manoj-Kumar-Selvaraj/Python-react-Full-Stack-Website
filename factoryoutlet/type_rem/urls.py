from django.urls import path
from .views import DeleteBarcodeType

urlpatterns = [
    path('delete-type/', DeleteBarcodeType.as_view(), name='delete-barcode-type'),
]
