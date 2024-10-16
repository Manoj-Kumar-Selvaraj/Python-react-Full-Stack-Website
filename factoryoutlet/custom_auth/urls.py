from django.urls import path
from .views import CustomAuthView

urlpatterns = [
    path('auth-token/', CustomAuthView.as_view(), name='auth-token'),
]
