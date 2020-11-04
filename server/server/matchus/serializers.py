from rest_framework import serializers
from .models import Photo, User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'interests', 'profile_photo']

    class AnonymousSerializer(serializers.ModelSerializer):
        anonymous = serializers.SerializerMethodField('get_anonymous')
        name = serializers.SerializerMethodField('get_name')

        class Meta:
            model = User
            fields = ['id', 'anonymous', 'name', 'profile_photo']

        def get_anonymous(self, obj):
            anonymous = self.context.get("anonymous")
            return bool(anonymous)

        def get_name(self, obj):
            anonymous = bool(self.context.get("anonymous"))
            return "Anonymous" if anonymous else obj.name

class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = ['photo']