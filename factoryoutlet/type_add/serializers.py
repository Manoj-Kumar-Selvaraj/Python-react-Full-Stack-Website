from rest_framework import serializers
from barcode.models import TypeT

class TypeTSerializer(serializers.ModelSerializer):
    class Meta:
        model = TypeT
        fields = '__all__'
