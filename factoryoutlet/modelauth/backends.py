from django.contrib.auth.backends import ModelBackend
from barcode.models import EmployeeT
import logging

# Create a logger instance
logger = logging.getLogger('modelauth')  # or use your app name

class EIDBackend(ModelBackend):
    def authenticate(self, request, eid=None, password=None, **kwargs):
        logger.debug(f"Attempting to authenticate user with eid: {eid}")
        try:
            user = EmployeeT.objects.get(eid=eid)
            if user.check_password(password):
                logger.debug(f"User {eid} authenticated successfully.")
                return user
        except EmployeeT.DoesNotExist:
            logger.error(f"User with eid {eid} does not exist")
            return None
