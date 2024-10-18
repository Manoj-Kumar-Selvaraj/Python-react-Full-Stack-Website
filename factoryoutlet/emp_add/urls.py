from django.urls import path
from .views import EmployeeTCreateView

urlpatterns = [
    path('access/', EmployeeTCreateView.as_view(), name='create_employee'),
    # Other URL patterns
]
