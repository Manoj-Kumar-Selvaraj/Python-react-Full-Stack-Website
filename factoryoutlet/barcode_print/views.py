from django.shortcuts import render
from .models import BarcodeT
from barcode.models import TypeT,EmployeeT
from django.utils import timezone
from .utils import return_400_if_object_found
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication
from rest_framework.permissions import IsAuthenticated
from django.core.exceptions import ValidationError

def barcode_print_init(request,barcodes, number_of_barcodes, pname, psize, ptype, seller, pamount):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]
    user=request.user.eid
    user_id=EmployeeT.objects.get(eid=user)
    # Check if a record already exists, and return a 400 error if found
    error_response = return_400_if_object_found(TypeT, BarcodeT, number_of_barcodes, pname=pname, psize=psize, ptype=ptype, pseller=seller, pamount=pamount)

    if error_response:
        return error_response  # Return the 400 response if object is found    
    else:
        print("Logic Failing")
    print("BarcodeT Insert Initiated")
    
    try:
        # Get b_type from TypeT table
        b_type_instance = TypeT.objects.filter(pname=pname, psize=psize, ptype=ptype, pseller=seller, pamount=pamount).first()
        
        if not b_type_instance:
            print("Error: No matching b_type found in TypeT.")
            return  # Handle this case as per your logic (e.g., return an error response)

        # Insert a new barcode record
        new_record = BarcodeT.objects.create(
            b_type=b_type_instance,  # Assign the instance of TypeT here
            number_of_barcodes=number_of_barcodes,
            eid=user_id,
            start_barcode=barcodes[0],  # First barcode in the list
            last_barcode=barcodes[-1],   # Last barcode in the list
            print_status=False,          # Boolean flag
            dog=timezone.now(),          # Date of generation (timestamp)
            print_slot='Y',              # Slot for printing
            gen_slot='Y',                # Slot for generation
            Approval='R'
        )
    except Exception as e:
        print(f"Error occurred: {e}")

