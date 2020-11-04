from django.contrib import admin
from .models import ChatRoom, User, Photo

admin.site.register(User)
admin.site.register(Photo)
admin.site.register(ChatRoom)