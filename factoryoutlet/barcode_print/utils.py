from django.http import JsonResponse

def return_400_if_object_found(model,number_of_barcodes, **filters):
    # Query the model using the filters
    obj = model.objects.filter(**filters).first()
    no_of_barcode_calculation=(obj.last_barcode-obj.start_barcode)
    
    # If the object is found, return a 400 Bad Request response
    if obj and no_of_barcode_calculation == number_of_barcodes:
        return JsonResponse({'error': 'Object already exists'}, status=400)
    
    # If no object is found, return None (meaning no error occurred)
    return None
