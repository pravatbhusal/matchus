from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.db.models import Q
from rest_framework import authentication, parsers, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import media_dir, Chat, Photo, User
from .serializers import ChatSerializer, PhotoSerializer, UserSerializer
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
            photo_url = media_dir + photo_name
            photo = Photo.objects.filter(user=request.user).filter(photo=photo_url)

            if not photo:
                return Response(status=status.HTTP_404_NOT_FOUND)

            # delete the photo
            photo.delete()
            return Response()

class ChatView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        chat_filter = Q(from_user=request.user) | Q(to_user=request.user)
        chats = Chat.objects.filter(chat_filter).values('from_user', 'to_user').distinct()

        messages = []
        for chat in chats:
            # determine the other user that's messaging this user
            user = None
            prefix = ""
            if chat['to_user'] == request.user.id:
                user = User.objects.filter(id=chat['from_user']).first()
            else:
                user = User.objects.filter(id=chat['to_user']).first()
                prefix = "You: "

            # receive the latest message between this user and the other user
            chat_filter = (Q(from_user=user) & Q(to_user=request.user)) | (Q(from_user=request.user) & Q(to_user=user))
            recent_chat = Chat.objects.filter(chat_filter).order_by('-id').first()

            # append the most recent message between the this user and the other user
            serializer = UserSerializer.ChatSerializer(user)
            message = { **serializer.data, "anonymous": recent_chat.anonymous, "message": prefix + recent_chat.message }
            messages.append(message)
        
        return Response(messages)

    class ChatProfileView(APIView):
        permission_classes = [permissions.IsAuthenticated]

        def get(self, request, *args, **kwargs):
            # receive the user of the profile id provided in the URL
            user_id = int(kwargs.get('id', 0))
            user = User.objects.filter(id=user_id).first()

            # receive all of the chats between the two users
            chat_filter = (Q(from_user=user) & Q(to_user=request.user)) | (Q(from_user=request.user) & Q(to_user=user))
            chats = Chat.objects.filter(chat_filter)

            serializer = ChatSerializer(chats, many=True)
            return Response(serializer.data)

class LogoutView(APIView):
    def post(self, request):
        logout(request)
        return Response()