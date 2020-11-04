from django.contrib.auth.models import AbstractUser
from django.utils.translation import ugettext_lazy as _
from django.utils.timezone import now
from django.db import models
from .managers import UserManager

media_dir = 'media/'

class User(AbstractUser):
    """
    Extends Django's base User model to implement custom fields and authentication.
    """

    # sets the email (instead of the username) as the unique identifier for the user model
    username = None
    email = models.EmailField(_('email address'), unique=True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    name = models.CharField(default="No Name", max_length=128)
    location = models.CharField(default="", max_length=128)
    interests = models.JSONField(default=list)
    profile_photo = models.ImageField(upload_to=media_dir)

    # helper methods for the User class
    objects = UserManager()

class Photo(models.Model):
    photo = models.ImageField(upload_to=media_dir)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

class Chat(models.Model):
    message = models.TextField()
    most_recent = models.BooleanField(default=True)
    date = models.DateTimeField(default=now)
    anonymous = models.BooleanField(default=True)
    from_user = models.ForeignKey(User, related_name='from_user', on_delete=models.CASCADE)
    to_user = models.ForeignKey(User, related_name='to_user', on_delete=models.CASCADE)