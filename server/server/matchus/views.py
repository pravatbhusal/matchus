from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from rest_framework import authentication, parsers, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import media_dir, Photo, User
from .serializers import UserSerializer, PhotoSerializer
from .forms import LoginForm, PhotoForm, SignUpForm, VerifyCredentialsForm
from notebook.matchus import similarity_matrix

class VerifyCredentialsView(APIView):
    def post(self, request):
        verify_credentials_form = VerifyCredentialsForm(request.data)
        if not verify_credentials_form.is_valid():
            return Response(verify_credentials_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        return Response()

class SignUpView(APIView):
    def post(self, request):
        signup_form = SignUpForm(request.data, request=request)
        if not signup_form.is_valid():
            return Response(signup_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        # create the user, login the user session, and return a success response
        user = signup_form.save()
        token, _ = Token.objects.get_or_create(user=user)
        success_response = { "token": token.key }
        return JsonResponse(success_response, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    def post(self, request):
        login_form = LoginForm(request.data, request=request)
        if not login_form.is_valid():
            return Response(login_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        # the user has been authenticated, so login the user session
        user = login_form.save()
        token, _ = Token.objects.get_or_create(user=user)
        success_response = { "token": token.key }
        return JsonResponse(success_response)

class ProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # receive the user of the profile id provided in the URL
        user_id = int(kwargs.get('id', 0))
        user = User.objects.filter(id=user_id).first()

        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        # receive the similarity between the logged-in user and the requested user
        similarity = similarity_matrix(request.user.interests, user.interests)
        match = { "match": similarity[0]["similarity"] }

        user_serializer = UserSerializer(user)
        return JsonResponse(dict(serializer.data, **match))

    class ProfilePhotoView(APIView):
        parser_classes = [parsers.FormParser, parsers.MultiPartParser]
        permission_classes = [permissions.IsAuthenticated]

        def post(self, request):
            photo_form = PhotoForm(request.POST, request.FILES)
            
            if not photo_form.is_valid():
                return Response(photo_form.errors, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

            # set this user's photo to the form's photo
            request.user.profile_photo = photo_form.cleaned_data['photo']
            request.user.save()

            return Response(status=status.HTTP_201_CREATED)

    class PhotosView(APIView):
        parser_classes = [parsers.FormParser, parsers.MultiPartParser]
        permission_classes = [permissions.IsAuthenticated]

        def post(self, request):
            photo_form = PhotoForm(request.POST, request.FILES)

            if not photo_form.is_valid():
                return Response(photo_form.errors, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

            # add this photo into the user's photos
            photo = Photo.objects.create(photo=photo_form.cleaned_data['photo'], user=request.user)
            return Response(status=status.HTTP_201_CREATED)

        def delete(self, request, *args, **kwargs):
            # receive the photo of the photo name provided in the URL
            photo_name = str(kwargs.get('name', ''))
            photo_name = media_dir + photo_name
            photo = Photo.objects.filter(user=request.user).filter(photo=photo_name)

            if not photo:
                return Response(status=status.HTTP_404_NOT_FOUND)

            # delete the photo
            photo.delete()
            return Response()

class LogoutView(APIView):
    def post(self, request):
        logout(request)
        return Response()