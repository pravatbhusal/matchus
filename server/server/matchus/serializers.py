from rest_framework import serializers
from .models import default_photo, Photo, User
from notebook.matchus import similarity

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

    class MatchSerializer(serializers.ModelSerializer):
        match = serializers.SerializerMethodField('get_match')
        photo = serializers.SerializerMethodField('get_photo')

        class Meta:
            model = User
            fields = ['id', 'match', 'name', 'interests', 'profile_photo', 'photo']

        def get_match(self, obj):
            user = self.context.get("user")

            # receive the similarity between this user and the other user
            match = similarity(obj.interests, user.interests)

            return match

        def get_photo(self, obj):
            user = User.objects.get(id=obj.id)
            photo = Photo.objects.filter(user=user).first()
            
            # serialize this photo
            photo_serializer = PhotoSerializer(photo)

            return photo_serializer.data["photo"] if photo else "/" + default_photo

class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = ['photo']