from django.http import JsonResponse

def return_400_if_object_found(model1, model2, number_of_barcodes, **filters):
    # Query the model1 using the filters
    obj = model1.objects.filter(**filters).first()
    
    # If no object is found in model1, return None (indicating no error)
    if not obj:
        return None
    
    # Query model2 using b_type from obj
    obj1 = model2.objects.filter(b_type=obj.b_type).first()
    
    # If no object is found in model2, handle the error (return None or an appropriate response)
    if not obj1:
        print("NULL")
    # Calculate the number of barcodes
    no_of_barcode_calculation = (obj1.last_barcode - obj1.start_barcode)
    
    # If the object is found and the barcode count matches, return a 400 Bad Request response
    if no_of_barcode_calculation == number_of_barcodes:
        return JsonResponse({'error': 'Object already exists'}, status=400)
    
    # If no object is found, return None (meaning no error occurred)
    return None
