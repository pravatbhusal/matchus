from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import UserAccount
from .serializers import UserAccountSerializer

class SignupView(APIView):
    def post(self, request):
        accounts = UserAccount.objects.all()
        serializer = UserAccountSerializer(accounts, many=True)
        return Response(serializer.data)