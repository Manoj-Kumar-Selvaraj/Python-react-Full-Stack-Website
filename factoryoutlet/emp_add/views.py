import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from barcode.models import EmployeeT
from django.utils import timezone
from barcode.authentication import CustomTokenAuthentication
from rest_framework.permissions import IsAuthenticated

class EmployeeTCreateView(APIView):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            # Extract fields from the request data
            data = request.data
            eid = data.get('eid')
            ename = data.get('ename')
            last_login = data.get('last_login', None)
            is_active = data.get('is_active', True)
            is_superuser = data.get('is_superuser', False)

            # Validate required fields
            if not eid or not ename:
                return Response({'error': 'eid and ename are required'}, status=status.HTTP_400_BAD_REQUEST)

            # Convert last_login to a datetime object if provided
            if last_login:
                last_login = timezone.make_aware(timezone.datetime.strptime(last_login, "%Y-%m-%dT%H:%M:%S"))

            # Create the EmployeeT instance
            employee = EmployeeT(
                eid=eid,
                ename=ename,
                last_login=last_login,
                is_active=is_active,
                is_superuser=is_superuser
            )
            employee.save()  # Save the employee to the database

            return Response({'message': 'Employee added successfully'}, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
