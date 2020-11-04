from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.db.models import Q
from rest_framework import authentication, parsers, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import media_dir, ChatRoom, Photo, User
from .serializers import PhotoSerializer, UserSerializer
from .forms import InterestForm, LoginForm, PhotoForm, SignUpForm, VerifyCredentialsForm
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
            photo = photo_form.cleaned_data['photo']
            request.user.profile_photo = photo
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
            photo = photo_form.cleaned_data['photo']
            Photo.objects.create(photo=photo, user=request.user)
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

    class InterestsView(APIView):
        permission_classes = [permissions.IsAuthenticated]

        def post(self, request):
            interest_form = InterestForm(request.data)

            if not interest_form.is_valid():
                return Response(interest_form.errors, status=status.HTTP_412_PRECONDITION_FAILED)

            # add this interest into the user's interests
            interest = interest_form.cleaned_data['interest']
            request.user.interests.append(interest)
            request.user.save()
            return Response(status=status.HTTP_201_CREATED)

        def delete(self, request, *args, **kwargs):
            # receive the interest index of the interest provided in the URL
            interest = str(kwargs.get('interest', ''))
            interest_index = -1
            try:
                interest_index = request.user.interests.index(interest)
            except:
                pass

            if interest_index == -1:
                return Response(status=status.HTTP_404_NOT_FOUND)

            # delete this interest from the user's interests
            del request.user.interests[interest_index]
            request.user.save()
            return Response()

class ChatView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        chat_filter = Q(user_A=request.user) | Q(user_B=request.user)
        chat_rooms = ChatRoom.objects.filter(chat_filter)

        messages = []
        for room in chat_rooms:
            # receive the latest message between this user and the other user
            recent_chat = room.chats[-1]

            # attributes to showcase for this recent message based on who the sender of the message was
            other_user = room.user_B if request.user == room.user_A else room.user_A
            message = recent_chat["message"]
            recent_chat["message"] = "You: " + message if recent_chat["id"] == request.user.id else message
            
            # make this user anonymous if the chat room is anonymous
            serializer = UserSerializer.AnonymousSerializer(other_user, context={ "anonymous": room.anonymous })

            messages.append({ **serializer.data, "message": recent_chat["message"] })
        
        return Response(messages)

    class ChatProfileView(APIView):
        permission_classes = [permissions.IsAuthenticated]

        def get(self, request, *args, **kwargs):
            # receive the user of the profile id provided in the URL
            user_id = int(kwargs.get('id', 0))
            user = User.objects.filter(id=user_id).first()

            # receive the chat room between the two users
            chat_filter = (Q(user_A=user) & Q(user_B=request.user)) | (Q(user_A=request.user) & Q(user_B=user))
            room = ChatRoom.objects.filter(chat_filter).first()

            # make these users anonymous if the chat room is still anonymous
            my_user_serializer = UserSerializer.AnonymousSerializer(request.user, context={ "anonymous": room.anonymous })
            other_user_serializer = UserSerializer.AnonymousSerializer(user, context={ "anonymous": room.anonymous })

            return Response({ "me": my_user_serializer.data, "other": other_user_serializer.data, "chats": room.chats })

class LogoutView(APIView):
    def post(self, request):
        logout(request)
        return Response()