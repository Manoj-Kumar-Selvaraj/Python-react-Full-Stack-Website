from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from barcode.models import TypeT
from barcode_print.models import BarcodeT
from .serializers import TypeTSerializer
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
def create_type(request):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]
    if request.method == 'POST':
        serializer = TypeTSerializer(data=request.data)
        
        # Check if the data is valid
        if serializer.is_valid():
            serializer.save()
            Barcodes=BarcodeT.objects.all()
            if Barcodes is None:
                for i in range(5):
                    BarT=BarcodT(b_type=serializer.b_type)
                    BarT.save()
            else:
                pass
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Create your views here.
