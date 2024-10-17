from django.db import models

class BarcodeT(models.Model):
    number_of_barcodes = models.IntField()
    start_barcode = models.BigIntegerField()  # Use BigIntegerField for large integers
    last_barcode = models.BigIntegerField()   # Use BigIntegerField for large integers
    print_status=models.BooleanField(default=False)
    dog = models.DateField(null=True, blank=True)
    print_slot = models.CharField(null=True, default='Y')
    gen_slot = models.CharField(null=True, default='Y')
    Approval = models.CharField(null=True, default='R')

    class Meta:
        db_table = 'BARCODE_T'  # Custom table name

    def __str__(self):
        return f"Start: {self.start_barcode}, Last: {self.last_barcode}"
