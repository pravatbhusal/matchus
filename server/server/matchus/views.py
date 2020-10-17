from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import User
from .forms import LoginForm, SignUpForm
from .serializers import UserSerializer

class SignUpView(APIView):
    def post(self, request, format=None):
        signup_form = SignUpForm(request.data)
        if not signup_form.is_valid():
            return Response(signup_form.errors, status=status.HTTP_409_CONFLICT)

        # create the user, login the user session, and return a success response
        user = signup_form.save()
        login(request, user)
        success_response = { "success": f"The user with the email {user.email} has been registered."}
        return Response(success_response)

class LoginView(APIView):
    def post(self, request, format=None):
        login_form = LoginForm(request.data, request=request)
        if not login_form.is_valid():
            return Response(login_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

        # the user has been authenticated, so login the user session
        user = login_form.save()
        success_response = { "success": f"Authenticated and logged-in {user.email}." }
        return Response(success_response)

class LogoutView(APIView):
    def post(self, request, format=None):
        logout(request)
        success_response = { "success": "Logged out the existing user and cleared the session." }
        return Response(success_response)