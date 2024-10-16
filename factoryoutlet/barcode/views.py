from django.shortcuts import render, get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .serializers import BarcodeCountSerializer, EmployeeTSerializer, ProductsTSerializer, TypeTSerializer
from .models import EmployeeT, ProductsT, TypeT
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from django.utils import timezone  # Import timezone
from rest_framework import status
from rest_framework.authtoken.views import ObtainAuthToken
from django.contrib.auth.hashers import check_password
from rest_framework.authtoken.models import Token
from custom_auth.views import CustomAuthView  # Correct import
from django.contrib.auth.models import User
from .authentication import CustomTokenAuthentication
class GenerateBarcodeView(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]
    def get(self, request):
        barcode_type = TypeT.objects.all()
        serializer = TypeTSerializer(barcode_type, many=True)
        return Response({"message": "GET SUCCESSFUL", "data": serializer.data}, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = BarcodeCountSerializer(data=request.data)
        if serializer.is_valid():
            number_of_barcodes = serializer.validated_data['number_of_barcodes']
            pname = request.data.get('Product Name')
            psize = request.data.get('Product Size')
            ptype = request.data.get('Product Type')
            seller = request.data.get('Seller')
            pamount = request.data.get('Amount')
            
            valid_type_instance = get_object_or_404(TypeT, pname=pname, psize=psize, ptype=ptype, pseller=seller, pamount=pamount)
            
            if valid_type_instance:
                last_barcode = valid_type_instance.last_barcode
                prefix = valid_type_instance.b_type
                
                # Generate new barcodes
                barcodes = self.new_barcode(prefix, number_of_barcodes, last_barcode)

                # Update last barcode and other fields
                valid_type_instance.last_barcode = barcodes[-1]  # Last generated barcode
                valid_type_instance.last_processed_date = timezone.now()
                valid_type_instance.lat_pid = valid_type_instance.lat + number_of_barcodes
                valid_type_instance.save()

                # Create ProductsT instances
                for barcode in barcodes:
                    ProductsT.objects.create(
                        pname=valid_type_instance.pname,
                        pseller=valid_type_instance.pseller,
                        psize=valid_type_instance.psize,
                        dop=valid_type_instance.last_processed_date,
                        pamount=valid_type_instance.pamount,
                        eid=valid_type_instance.eid,
                        bar_code=barcode,
                        status='N'
                    )

                return Response({"message": "Barcodes generated successfully", "barcodes": barcodes}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def new_barcode(self, prefix, number, last_barcode):
        """
        Generate a new barcode based on the last barcode.
        """
        barcodes = []
       #  last_code = int(str(last_barcode)[3:13])  # Assuming last 10 chars are numeric
        
        for _ in range(number):
            last_code += 1
            barcode_l = f"{prefix}{last_barcode:010d}"  # Ensure numeric part has leading zeros
            digits = [int(d) for d in barcode_l]
            odd_sum = sum(digits[i] for i in range(0, 12, 2))
            even_sum = sum(digits[i] for i in range(1, 12, 2)) * 3
            total_sum = odd_sum + even_sum
            checksum = (10 - (total_sum % 10)) % 10
            barcode = f"{prefix}{last_barcode:010d}{checksum}"
            barcodes.append(barcode)
        
        return barcodes
