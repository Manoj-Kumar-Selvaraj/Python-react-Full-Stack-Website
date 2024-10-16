# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.utils import timezone
from django.conf import settings
from django.db import models
import uuid

class EmployeeT(models.Model):
    eid = models.CharField(max_length=100, unique=True, primary_key=True)
    ename = models.CharField(max_length=20)
    last_login = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


    class Meta:
        db_table = 'EMPLOYEE_T'

    @property
    def is_authenticated(self):
        return True  # Since this is expected for logged-in users

class CustomToken(models.Model):
    eid = models.ForeignKey(EmployeeT, models.DO_NOTHING, db_column='eid', primary_key=True) 
    key = models.CharField(max_length=40, unique=True) 
    created = models.DateTimeField(auto_now_add=True)
    password = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'OLD_PRODUCT_DATA'
    def is_password_correct(self, password):
        return check_password(password, self.password)  # Check the hashed password

class ProductsT(models.Model):
    pid = models.AutoField(primary_key=True)
    pname = models.CharField(max_length=50, blank=True, null=True)
    pseller = models.CharField(max_length=50, blank=True, null=True)
    psize = models.CharField(max_length=10, blank=True, null=True)
    dop = models.DateField(blank=True, null=True)
    dos = models.DateField(blank=True, null=True)
    pamount = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    eid = models.ForeignKey(EmployeeT, models.DO_NOTHING, db_column='eid', blank=True, null=True)
    bar_code = models.IntegerField(blank=True, null=True)
    bamount = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    status = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'PRODUCTS_T'

class TypeT(models.Model):
    psize = models.CharField(max_length=10, blank=True, null=True)
    pname = models.CharField(max_length=50, blank=True, null=True)
    ptype = models.CharField(max_length=50, blank=True, null=True)
    pseller = models.CharField(max_length=50, blank=True, null=True)
    b_type = models.CharField(primary_key=True, max_length=20)
    last_processed_date = models.DateField(blank=True, null=True)
    last_barcode = models.IntegerField(blank=True, null=True)
    eid = models.ForeignKey(EmployeeT, models.DO_NOTHING, db_column='eid', blank=True, null=True)
    lat_pid = models.IntegerField(blank=True, null=True)
    pamount = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'TYPE_T'


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.IntegerField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.IntegerField()
    is_active = models.IntegerField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.PositiveSmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'
