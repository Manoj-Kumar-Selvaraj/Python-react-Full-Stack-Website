from django.shortcuts import render, get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import EmployeeT, ProductsT, TypeT
from barcode_print.models import BarcodeT
from django.utils import timezone
from custom_auth.views import CustomAuthView
from .authentication import CustomTokenAuthentication
from barcode_print.views import barcode_print_init

class BarcodePdf(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        b_type=request.data.get('b_type')
        control_rec=BarcodeT.objects.filter(b_type=b_type,print_status=False)
        barcode_instance = ProductsT.objects.filter(b_type=b_type,my_field__range=(control_rec.start_barcode,control_rec.last_barcode))
        barcode_list=list(barcode_instance.bar_code )
        if contro_rec:
            generate_pdf(barcode_list)
        slot_instance=BarcodeT.objects.filter(print_slot='N')
        # Logic Need to be developed to avoid two rows in the query set
        elif slot_instance:
            call_pdf()
            slot_instance.print_slot='Y'
        control_rec.print_status=True
        return Response({"message": "GET SUCCESSFUL", "data": serializer.data}, status=status.HTTP_200_OK)
    def
