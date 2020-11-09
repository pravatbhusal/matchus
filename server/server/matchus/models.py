from django.contrib.auth.models import AbstractUser
from django.utils.translation import ugettext_lazy as _
from django.utils.timezone import now
from django.db import models
from .managers import UserManager

media_dir = 'media/'
default_photo = "assets/default.png"
default_profile_photo = "assets/profile-default.png"

class User(AbstractUser):
    """
    Extends Django's base User model to implement custom fields and authentication.
    """

    # sets the email (instead of the username) as the unique identifier for the user model
    username = None
    first_name = None
    last_name = None
    email = models.EmailField(_('email address'), unique=True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    name = models.CharField(default="No Name", max_length=128)
    location = models.CharField(default="", max_length=128)
    interests = models.JSONField(default=list)
    biography = models.CharField(default="", max_length=512)
    latitude = models.DecimalField(default=0, max_digits=16, decimal_places=12)
    longitude = models.DecimalField(default=0, max_digits=16, decimal_places=12)
    profile_photo = models.ImageField(upload_to=media_dir)

    # helper methods for the User class
    objects = UserManager()

class Photo(models.Model):
    photo = models.ImageField(upload_to=media_dir)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

class ChatRoom(models.Model):
    anonymous = models.BooleanField(default=True)
    request_identity_from = models.ForeignKey(User, default=None, blank=True, null=True, related_name='request_identity_from', on_delete=models.CASCADE)
    user_A = models.ForeignKey(User, related_name='user_A', on_delete=models.CASCADE)
    user_B = models.ForeignKey(User, related_name='user_B', on_delete=models.CASCADE)
    chats = models.JSONField(default=list)