from django.db import models
from barcode.models import TypeT
from datetime import date

class BarcodeT(models.Model):
    id = models.AutoField(primary_key=True)
    b_type = models.ForeignKey(TypeT, models.DO_NOTHING, db_column='b_type')
    number_of_barcodes = models.IntegerField(default=0)
    start_barcode = models.BigIntegerField(default=0)  # Use BigIntegerField for large integers
    last_barcode = models.BigIntegerField(default=0)   # Use BigIntegerField for large integers
    print_status=models.BooleanField(default=True)
    dog = models.DateField(default=date(1,1,1))
    print_slot = models.CharField(null=True, default='N',max_length=1)
    gen_slot = models.CharField(null=True, default='N',max_length=1)
    Approval = models.CharField(null=True, default='A',max_length=1)

    class Meta:
        db_table = 'BARCODE_T'  # Custom table name

    def __str__(self):
        return f"Start: {self.start_barcode}, Last: {self.last_barcode}"
