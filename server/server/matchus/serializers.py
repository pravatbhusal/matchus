from rest_framework import serializers
from .models import Chat, Photo, User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'interests', 'profile_photo']

    class ChatSerializer(serializers.ModelSerializer):
        class Meta:
            model = User
            fields = ['id', 'name', 'profile_photo']

class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = ['photo']

class ChatSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(source='from_user.id')
    name = serializers.CharField(source='from_user.name')
    profile_photo = serializers.ImageField(source='from_user.profile_photo')

    class Meta:
        model = Chat
        fields = ['message', 'date', 'anonymous', 'id', 'name', 'profile_photo']