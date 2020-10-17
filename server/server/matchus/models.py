from django.contrib.auth.models import AbstractUser
from django.utils.translation import ugettext_lazy as _
from django.db import models
from .managers import UserManager

class User(AbstractUser):
    # sets the email (instead of the username) as the unique identifier for the user model
    username = None
    email = models.EmailField(_('email address'), unique=True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    location = models.CharField(default=None, blank=True, null=True, max_length=128)
    interests = models.JSONField(default=None, blank=True, null=True)

    # manager (helper methods) for the User class
    objects = UserManager()