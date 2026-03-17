from django.db import models
from .users import Users


class UserHosts(models.Model):
    user_id = models.ForeignKey(Users, on_delete=models.CASCADE, db_index=True)
    host = models.CharField(max_length=255, db_index=True)
    system_password = models.CharField(max_length=255, db_index=True)

    # NEW: Ed25519 public key for JWT authentication with hosts
    # This public key is used to verify JWT tokens sent by this host
    ed25519_public_key = models.TextField(blank=True, null=True, default=None)

    priority = models.IntegerField(default=0, db_index=True)
    status = models.IntegerField(default=1, db_index=True)
    allow_sms = models.IntegerField(default=0, db_index=True)


    def __str__(self):
        return f"UserHosts(id={self.id}, user_id={self.user_id}, host={self.host}, system_password={self.system_password})"

    class Meta:
        unique_together = ('user_id', 'host')
        unique_together = ('host', 'priority')
