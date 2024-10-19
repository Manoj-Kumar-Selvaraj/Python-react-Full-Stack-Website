import json
from django.http import JsonResponse
from django.views import View
from barcode.models import EmployeeT
from django.utils import timezone
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication
class EmployeeTCreateView(View):
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]
    authentication_classes = [CustomTokenAuthentication]
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        try:
            # Parse the JSON request body
            data = json.loads(request.body)
            
            # Extract fields from the request data
            eid = data.get('eid')
            ename = data.get('ename')
            last_login = data.get('last_login', None)
            is_active = data.get('is_active', True)
            is_superuser = data.get('is_superuser', False)

            # Validate required fields
            if not eid or not ename:
                return JsonResponse({'error': 'eid and ename are required'}, status=400)

            # Convert last_login to a datetime object if provided
            if last_login:
                last_login = timezone.datetime.strptime(last_login, "%Y-%m-%dT%H:%M:%S")

            # Create the EmployeeT instance
            employee = EmployeeT(
                eid=eid,
                ename=ename,
                last_login=last_login,
                is_active=is_active,
                is_superuser=is_superuser
            )
            employee.save()  # Save the employee to the database

            return JsonResponse({'message': 'Employee added successfully'}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
