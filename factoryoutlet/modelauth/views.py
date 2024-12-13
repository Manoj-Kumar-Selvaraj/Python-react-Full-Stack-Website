from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from barcode.models import CustomToken
from rest_framework.permissions import AllowAny

class CustomLoginView(APIView):
    permission_classes=[AllowAny]
    def post(self, request):
        eid = request.data.get('eid')
        password = request.data.get('password')

        # Authenticate using the eid (employee ID) and password
        user = authenticate(request, eid=eid, password=password)
        
        if user is not None:
            # Generate or retrieve the token
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
