from django.shortcuts import render
from rest_framework.permissions import IsAuthenticated
from custom_auth.views import CustomAuthView
from barcode.authentication import CustomTokenAuthentication

# Create your views here.
