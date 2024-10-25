from django.urls import path
from .views import EmployeeTDeactivateView

urlpatterns = [
    path('access/', EmployeeTDeactivateView.as_view(), name='create_employee'),
    # Other URL patterns
]
