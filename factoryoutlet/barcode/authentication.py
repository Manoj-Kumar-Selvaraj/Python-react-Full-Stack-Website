from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from .models import CustomToken

class CustomTokenAuthentication(BaseAuthentication):
    def authenticate(self, request):
        token = request.headers.get('Authorization')
        # print(f'Token received from Client: {token}')
        if not token:
            return None
        # Strip "Token " prefix if present
        if token.startswith("Token "):
            token = token.split("Token ")[1]
        print(f'Token received from Client: {token}') 
        try:
            custom_token = CustomToken.objects.get(key=token)
            employee = custom_token.eid  # Reference to eid (EmployeeT model)
        except CustomToken.DoesNotExist:
            raise AuthenticationFailed('Invalid token')

        return (employee, None)  # Returning the employee object
