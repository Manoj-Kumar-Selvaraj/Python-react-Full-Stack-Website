from django.shortcuts import render, get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from barcode.serializers import BarcodeCountSerializer, TypeTSerializer
from barcode.models import TypeT
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication

class DeleteBarcodeType(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        barcode_types = TypeT.objects.all()
        serializer = TypeTSerializer(barcode_types, many=True)
        return Response({"message": "GET SUCCESSFUL", "data": serializer.data}, status=status.HTTP_200_OK)

    def post(self, request):
            pname = request.data.get('pname')
            psize = request.data.get('psize')
            ptype = request.data.get('ptype')
            seller = request.data.get('pseller')
            pamount = request.data.get('pamount')
            print(pname)
            print(psize)
            print(ptype)
            print(seller)
            print(pamount) 
            # Retrieve the TypeT instance or return 404 if not found
            valid_type_instance = get_object_or_404(TypeT, pname=pname, psize=psize, ptype=ptype, pseller=seller, pamount=pamount)
            if valid_type_instance:
                # If the instance is found, delete it
                valid_type_instance.delete()

                # Return a success response
                return Response({"message": "Product type deleted successfully"}, status=status.HTTP_200_OK)

            else:
                # If the serializer is not valid, return errors
                return Response({"message": "Product Type Not found"}, status=status.HTTP_400_BAD_REQUEST)
