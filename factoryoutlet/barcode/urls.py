# your_app_name/urls.py

from django.urls import path
from .views import GenerateBarcodeView,BarcodeTSlotView

urlpatterns = [
    path('generate-barcode/', GenerateBarcodeView.as_view(), name='generate_barcode'),
    path('barcode_log/',BarcodeTSlotView.as_view(), name='barcode_log'),
]

