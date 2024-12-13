# serializers.py
from rest_framework import serializers
from .models import BarcodeT  # replace with your actual model

class BarcodeTSerializer(serializers.ModelSerializer):
    class Meta:
        model = BarcodeT
        fields = '__all__'  # Or specify the fields you want to include
