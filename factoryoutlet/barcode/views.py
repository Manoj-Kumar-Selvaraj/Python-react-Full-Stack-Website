from django.shortcuts import render, get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .serializers import BarcodeCountSerializer, EmployeeTSerializer, ProductsTSerializer, TypeTSerializer
from .models import EmployeeT, ProductsT, TypeT
from django.utils import timezone
from custom_auth.views import CustomAuthView
from .authentication import CustomTokenAuthentication

class GenerateBarcodeView(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        barcode_types = TypeT.objects.all()
        serializer = TypeTSerializer(barcode_types, many=True)
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
                valid_type_instance.save()

                # Create ProductsT instances
                for barcode in barcodes:
                    ProductsT.objects.create(
                        pname=valid_type_instance.pname,
                        pseller=valid_type_instance.pseller,
                        psize=valid_type_instance.psize,
                        dop=valid_type_instance.last_processed_date,
                        pamount=valid_type_instance.pamount,
                        bar_code=barcode,
                        status='N'
                    )

                return Response({"message": "Barcodes generated successfully", "barcodes": barcodes}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def new_barcode(self, prefix, number, last_barcode):
        """
        Generate new barcodes based on the last barcode.
        """
        barcodes = []
        
        for _ in range(number):
            # Increment the last barcode number
            last_barcode += 10
            
            # Convert last_barcode to string
            last_barcode_str = str(last_barcode)

            # Pad with zeros to the left if less than 8 digits
            if len(last_barcode_str) < 8:
                last_barcode_str = last_barcode_str.zfill(8)  # Pad with zeros to 8 digits
            
            # Only take the last 8 digits if more than 8 digits
            if len(last_barcode_str) > 8:
                last_barcode_str = last_barcode_str[-8:]  # Take the last 8 digits

            # Create the barcode string without the checksum
            barcode_without_checksum = f"{prefix}{last_barcode_str}"  # Combine prefix and last_barcode_str
            
            # Log the barcode without checksum and its length
            print(f"Barcode without checksum: {barcode_without_checksum} (Length: {len(barcode_without_checksum)})")

            # Ensure that barcode_without_checksum is 12 digits long
            if len(barcode_without_checksum) != 12:
                print(f"Error: The combination of prefix '{prefix}' and last_barcode '{last_barcode_str}' results in an invalid length.")
                return []  # Handle this case appropriately
            
            # Convert barcode string into a list of digits
            digits = [int(d) for d in barcode_without_checksum]
            
            # Calculate sums for checksum calculation
            odd_sum = sum(digits[i] for i in range(0, 12, 2))  # Sum of digits in odd positions
            even_sum = sum(digits[i] for i in range(1, 12, 2)) * 3  # Sum of digits in even positions times 3
            
            # Calculate total sum and checksum
            total_sum = odd_sum + even_sum
            checksum = (10 - (total_sum % 10)) % 10
            
            # Construct the final barcode with checksum
            barcode = f"{barcode_without_checksum}{checksum}"
            
            # Add the barcode to the list
            barcodes.append(barcode)

        return barcodes
