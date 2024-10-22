from django.shortcuts import render
from barcode.models import TypeT
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from type_add.serializers import TypeTSerializer
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.permissions import AllowAny

@api_view(['GET'])
def select_type(request):
    # authentication_classes = [CustomTokenAuthentication]
    # permission_classes = [IsAuthenticated]
    permission_classes = AllowAny
    if request.method == 'GET':
        type_records = TypeT.objects.all()
        # Serialize the records
        serializer = TypeTSerializer(type_records, many=True)
        # Return the serialized data as JSON
        print(serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK)
        


# Create your views here.
