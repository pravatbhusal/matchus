from django.shortcuts import render
from django.contrib.auth import login
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from .constants import PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH
from .models import User
from .serializers import UserSerializer

class SignupView(APIView):
    def post(self, request, format=None):
        email = request.data['email']
        password = request.data['password']

        account_exists = User.objects.filter(email=email).exists()
        if account_exists:
            # account already exists for this email, so return a conflicted response
            error_response = { "error": f"User already exists for the email {email}."}
            return Response(error_response, status=status.HTTP_409_CONFLICT)

        if len(password) < PASSWORD_MIN_LENGTH or len(password) > PASSWORD_MAX_LENGTH:
            # the password is either too short or too long
            error_response = { "error": "The password is either too short or too long."}
            return Response(error_response, status=status.HTTP_409_CONFLICT)
        
        # create an account with the provided credentials, then login the user
        user = User.objects.create_user(username=email, email=email, password=password)
        login(request, user)
        success_response = { "success": f"The user with the email {email} has been registered."}
        return Response(success_response)