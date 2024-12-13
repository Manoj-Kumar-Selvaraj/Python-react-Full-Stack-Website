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
from reportlab.pdfgen import canvas
from django.http import HttpResponse
import io

class BarcodePdf(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        request_type = request.data.get('type')
        page_width_mm = request.data.get('page_width_mm')  # Width in mm
        page_height_mm = request.data.get('page_height_mm')  # Height in mm
        b_type = request.data.get('b_type')

        control_rec, barcode_list = self.logic_selection(b_type, request_type)
        
        if control_rec:
            pdf_buffer = self.generate_pdf(barcode_list, page_width_mm, page_height_mm)

            # Return the generated PDF as an HTTP response
            response = HttpResponse(pdf_buffer, content_type='application/pdf')
            response['Content-Disposition'] = 'inline; filename="barcodes.pdf"'
            return response
        else:
            return Response({"message": "No Active Print Request from Admin"}, status=status.HTTP_404_NOT_FOUND)

    def generate_pdf(self, barcode_list, page_width_mm, page_height_mm):
        # Convert dimensions from mm to points (1 mm ≈ 2.83465 points)
        page_width = float(page_width_mm) * 2.83465
        page_height = float(page_height_mm) * 2.83465
        pagesize = (page_width, page_height)

        # Create a PDF in memory with the specified custom page size
        buffer = io.BytesIO()
        pdf_canvas = canvas.Canvas(buffer, pagesize=pagesize)

        y_position = page_height - 20  # Starting position from the top of the page
        pdf_canvas.setFont("Helvetica", 10)  # Adjust font size as needed

        for barcode in barcode_list:
            pdf_canvas.drawString(10, y_position, str(barcode))  # Adjust X and Y positions as needed
            y_position -= 15  # Move down for the next barcode
            
            # Add a new page if necessary
            if y_position < 20:
                pdf_canvas.showPage()
                y_position = page_height - 20

        pdf_canvas.save()

        # Set the PDF to the beginning of the buffer
        buffer.seek(0)
        return buffer

    def logic_selection(self, b_type, request_type):
        try:
            if request_type == 'print':
                control_rec = BarcodeT.objects.get(b_type=b_type, print_status=False)
                # Update control record's print status and save
                control_rec.print_status = True
                control_rec.save()
            elif request_type == 'reprint':
                control_rec = BarcodeT.objects.get(b_type=b_type, print_slot='N')
                control_rec.print_slot = 'Y'  # Mark the reprint slot as printed
                control_rec.save()
            else:
                return None, []

            # Query ProductsT within the barcode range of the control record
            barcode_instance = ProductsT.objects.filter(
                b_type=b_type,
                my_field__range=(control_rec.start_barcode, control_rec.last_barcode)
            )
            barcode_list = [item.bar_code for item in barcode_instance]

            return control_rec, barcode_list
        except BarcodeT.DoesNotExist:
            return None, []
