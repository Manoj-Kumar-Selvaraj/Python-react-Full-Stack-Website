from django.http import JsonResponse

def return_400_if_object_found(model, **filters):
    # Query the model using the filters
    obj = model.objects.filter(**filters).first()
    
    # If the object is found, return a 400 Bad Request response
    if obj:
        return JsonResponse({'error': 'Object already exists'}, status=400)
    
    # If no object is found, return None (meaning no error occurred)
    return None
