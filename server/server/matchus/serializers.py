from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'name', 'interests', 'profile_photo', )

    class UserPhotoSerializer(serializers.ModelSerializer):
        class Meta:
            model = User
            fields = ('profile_photo', )
