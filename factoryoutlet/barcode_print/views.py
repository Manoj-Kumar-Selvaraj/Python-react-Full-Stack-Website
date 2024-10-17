from django.shortcuts import render
from .models import BarcodeT
from django.utils import timezone
from .utils import return_400_if_object_found

def barcode_print_init(barcodes, number_of_barcodes, pname, psize, ptype, seller, pamount):
    # Check if a record already exists, and return a 400 error if found
    error_response = return_400_if_object_found(BarcodeT, number_of_barcodes=number_of_barcodes, pname=pname, psize=psize, ptype=ptype, seller=seller, pamount=pamount)
    if error_response and error_response.gen_slot=='Y':
        return error_response  # Return the 400 response if object is found

    # Insert a new barcode record
    BarcodeT.objects.create(
        number_of_barcodes=number_of_barcodes,
        start_barcode=barcodes[0],        # First barcode in the list
        last_barcode=barcodes[-1],        # Last barcode in the list
        print_status=False,               # Boolean flag
        dog=timezone.now(),               # Date of generation (timestamp)
        print_slot='Y',                   # Slot for printing
        gen_slot='Y'                      # Slot for generation
        Approval='R'
    )


    # Retrieve all barcode records, ordered by 'start_barcode' (oldest first)
    records = BarcodeT.objects.all().order_by('start_barcode')
    
    # If there are more than 5 records, delete the excess ones
    if records.count() > 5:
        excess_records = records[:records.count() - 5]  # Slice to get the oldest records
        excess_records.delete()  # Delete the oldest excess records
