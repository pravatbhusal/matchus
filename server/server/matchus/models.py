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

    # manager (helper methods) for the User class
    objects = UserManager()