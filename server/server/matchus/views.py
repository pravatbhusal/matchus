from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from rest_framework import authentication, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import User
from .forms import LoginForm, SignUpForm, VerifyCredentialsForm

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
        return Response(success_response, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    def post(self, request, format=None):
        login_form = LoginForm(request.data, request=request)
        if not login_form.is_valid():
            return Response(login_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        # the user has been authenticated, so login the user session
        user = login_form.save()
        token, _ = Token.objects.get_or_create(user=user)
        success_response = { "token": token.key }
        return Response(success_response)

class LogoutView(APIView):
    def post(self, request, format=None):
        logout(request)
        success_response = { "success": "Logged out the existing user and cleared the session." }
        return Response(success_response)