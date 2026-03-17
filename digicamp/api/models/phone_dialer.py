from django.db import models
from django.db.models import Func

class CurrentTimestamp(Func):
    template = 'CURRENT_TIMESTAMP'

'''
Sent status 
0 - Not sent
1 - In progress
2 - Unanswered
3 - Ongoing Call
4 - cancelled
5 - Completed
'''


class PhoneDialer(models.Model):
    phone_number = models.CharField(max_length=10, db_index=True)
    user = models.ForeignKey('Users', on_delete=models.CASCADE, db_index=True)
    campaign = models.ForeignKey('Campaign', on_delete=models.CASCADE, db_index=True)
    sent_status = models.IntegerField(null=True, blank=True, default=0, db_index=True)
    name = models.CharField(max_length=255, db_index=True, null=True, blank=True, default=None)
    sent_datetime = models.DateTimeField(null=True, blank=True, default=None, db_index=True)
    trials = models.IntegerField(null=True, blank=True, default=0, db_index=True)
    call_through = models.CharField(max_length=10, db_index=True, default=None, null=True, blank=True)
    duration = models.IntegerField(null=True, blank=True, default=0, db_index=True)
    created_at = models.DateTimeField(db_index=True)
    updated_at = models.DateTimeField(db_index=True)
    block_trials = models.IntegerField(null=True, blank=True, default=0, db_index=True)

    class Meta:
        db_table = 'api_phone_dialer'

    def save(self, *args, **kwargs):
        if not self.id:
            self.created_at = CurrentTimestamp()
        self.updated_at = CurrentTimestamp()
        super().save(*args, **kwargs)