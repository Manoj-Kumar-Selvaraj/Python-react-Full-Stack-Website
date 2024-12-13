import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from barcode.models import EmployeeT
from django.utils import timezone
from barcode.authentication import CustomTokenAuthentication
from rest_framework.permissions import IsAuthenticated

class EmployeeTDeactivateView(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            # Extract fields from the request data
            data = request.data
            eid = data.get('eid')
            is_active = data.get('is_active', False)

            # Validate required fields
            if not eid:
                return Response({'error': 'Please Enter the Employee Id'}, status=status.HTTP_400_BAD_REQUEST)

            # Create the EmployeeT instance
            employee = EmployeeT(
                eid=eid,
                is_active = is_active
            )
            employee.save()  # Save the employee to the database

            return Response({'message': 'Employee Deactivated successfully'}, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
