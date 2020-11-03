from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from rest_framework import authentication, parsers, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import User
from .serializers import UserSerializer
from .forms import LoginForm, SignUpForm, VerifyCredentialsForm
from notebook.matchus import similarity_matrix

class VerifyCredentialsView(APIView):
    def post(self, request, format=None):
        verify_credentials_form = VerifyCredentialsForm(request.data)
        if not verify_credentials_form.is_valid():
            return Response(verify_credentials_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        return Response()

class SignUpView(APIView):
    def post(self, request, format=None):
        signup_form = SignUpForm(request.data, request=request)
        if not signup_form.is_valid():
            return Response(signup_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        # create the user, login the user session, and return a success response
        user = signup_form.save()
        token, _ = Token.objects.get_or_create(user=user)
        success_response = { "token": token.key }
        return JsonResponse(success_response, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    def post(self, request, format=None):
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

    def get(self, request, format=None, *args, **kwargs):
        # receive the user of the profile id provided in the URL
        user_id = int(kwargs.get('id', 0))
        user = User.objects.filter(id=user_id).first()

        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        # receive the similarity between the logged-in user and the requested user
        similarity = similarity_matrix(request.user.interests, user.interests)
        match = { "match": similarity[0]["similarity"] }

        serializer = UserSerializer(user)
        return JsonResponse(dict(serializer.data, **match))

    def patch(self, request, format=None, *args, **kwargs):
        # update the relevant fields based on the request's body
        for prop in request.data:
            setattr(request.user, prop, request.data[prop])
        request.user.save()
        
        serializer = UserSerializer(request.user)
        return JsonResponse(serializer.data)

    class ProfilePhotoView(APIView):
        parser_classes = [parsers.FormParser, parsers.MultiPartParser]

        def put(self, request, format=None):
            return Response()

    class PhotosView(APIView):
        parser_classes = [parsers.FormParser, parsers.MultiPartParser]

        def get(self, request, format=None):
            return Response()

class LogoutView(APIView):
    def post(self, request, format=None):
        logout(request)
        return Response()