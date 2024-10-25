from django.urls import path
from .views import EmployeeTCreateView,EmployeeSelectView

urlpatterns = [
    path('access/', EmployeeTCreateView.as_view(), name='create_employee'),
    path('select/', EmployeeTSelectView.as_view(), name='create_employee'),
    # Other URL patterns
]
