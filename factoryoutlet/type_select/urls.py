from django.urls import path
from .views import select_type

urlpatterns = [
    path('type-records/', select_type, name='type-records'),
]
