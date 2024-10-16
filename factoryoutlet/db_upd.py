import django
django.setup()
from barcode.models import EmployeeT
from barcode.models import User
# Create a new employee entry
employee = EmployeeT(eid='E0000007', ename='John Doe', password='FactoryOutlet@3')
employee.save()

