from rest_framework.response import Response
from rest_framework.views import APIView
from barcode.models import CustomToken  # Import your CustomToken model
from rest_framework.permissions import AllowAny
from django.contrib.auth.hashers import make_password, check_password
from uuid import uuid4
from rest_framework import status

class CustomAuthView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        eid = request.data.get('eid')  # Employee ID
        password = request.data.get('password')  # Password

        try:
            # Check if the token exists for the employee
            token = CustomToken.objects.get(eid=eid)
            # Verify the password
            if check_password(password, token.password):
                # Generate a new token and save it
                new_token = str(uuid4())
                token.key = new_token  # Update the token key
                token.save()  # Save the updated token
                print(f'Token Generated in Backend: {new_token}')
                return Response({'token': new_token}, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
        except CustomToken.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
