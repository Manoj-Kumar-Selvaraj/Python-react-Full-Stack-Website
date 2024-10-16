# your_app_name/urls.py

from django.urls import path
from .views import GenerateBarcodeView

urlpatterns = [
    path('generate-barcode/', GenerateBarcodeView.as_view(), name='generate_barcode'),
]
