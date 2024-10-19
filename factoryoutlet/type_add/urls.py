from django.urls import path
from .views import create_type

urlpatterns = [
    path('create-type/', create_type, name='create_type'),
]
