from django.shortcuts import render
from .models import BarcodeT
from django.utils import timezone

def barcode_print_init(barcodes):
    BarcodeT.objects.create(
            start_barcode = barcodes[0]
            last_barcode = barcodes[-1]   # Use BigIntegerField for large integers
            print_status= False
            generate_status = True
            dog = timezone.now()
            print_slot = 'Y'
            gen_slot = 'N'
    )



# Create your views here.
