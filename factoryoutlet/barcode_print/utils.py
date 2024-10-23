from django.http import JsonResponse

def return_400_if_object_found(model1, model2, number_of_barcodes, **filters):
    # Query the model using the filters
    obj = model1.objects.filter(**filters).first()
    obj1 = model2.objects.filter(obj.b_type).first()
    no_of_barcode_calculation=(obj1.last_barcode-obj1.start_barcode)
    
    # If the object is found, return a 400 Bad Request response
    if obj and no_of_barcode_calculation == number_of_barcodes:
        return JsonResponse({'error': 'Object already exists'}, status=400)
    
    # If no object is found, return None (meaning no error occurred)
    return None
