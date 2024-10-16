from django.urls import path
from .views import CustomLoginView

urlpatterns = [
    path('auth-token/', CustomLoginView.as_view(), name='auth-token'),
]
