from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from barcode.models import TypeT
from barcode_print.models import BarcodeT
from .serializers import TypeTSerializer
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication
from rest_framework.permissions import IsAuthenticated
from barcode_print.models import BarcodeT
from barcode.models import TypeT

@api_view(['POST'])

def create_type(request):
    serializer = TypeTSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        Barcodes = BarcodeT.objects.all()
        print(Barcodes)

        if not Barcodes.exists():
            # Retrieve the TypeT instance for the given b_type
            b_type_value = serializer.validated_data['b_type']  # Assuming this is a string or ID
            try:
                b_type_instance = TypeT.objects.get(b_type=b_type_value)  # Fetch the TypeT instance
            except TypeT.DoesNotExist:
                return Response({"error": "TypeT instance not found."}, status=status.HTTP_400_BAD_REQUEST)

            for i in range(5):
                BarT = BarcodeT(
                    b_type=b_type_instance,  # Assign the instance of TypeT
                )
                BarT.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response({"message": "Barcodes already exist."}, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


