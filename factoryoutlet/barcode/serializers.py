from rest_framework import serializers
from .models import EmployeeT,ProductsT,TypeT

class EmployeeTSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmployeeT
        fields = '__all__'


class ProductsTSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductsT
        fields = '__all__'

class TypeTSerializer(serializers.ModelSerializer):
    class Meta:
        model = TypeT
        fields = '__all__'

class BarcodeCountSerializer(serializers.Serializer):
    number_of_barcodes = serializers.IntegerField(min_value=1)
