from rest_framework import serializers
from .models import User, Photo

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'interests', 'profile_photo']

    class UserPhotoSerializer(serializers.ModelSerializer):
        class Meta:
            model = User
            fields = ['profile_photo']

class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = ['photo']