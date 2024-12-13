from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from barcode.models import EmployeeT

class Command(BaseCommand):
    help = "Link EmployeeT records with corresponding User instances"

    def handle(self, *args, **kwargs):
        employees = EmployeeT.objects.all()

        for employee in employees:
            # Check if a User already exists for the Employee
            if not employee.user:
                # Create a User for the Employee
                user = User.objects.create_user(username=employee.eid, password=employee.password)
                # Link the Employee to the User
                employee.user = user
                employee.save()

        self.stdout.write(self.style.SUCCESS('Successfully linked EmployeeT records to User instances.'))
