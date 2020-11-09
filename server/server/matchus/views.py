from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.db.models import Q
from rest_framework import authentication, parsers, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import media_dir, ChatRoom, Photo, User
from .serializers import ChatRoomSerializer, PhotoSerializer, UserSerializer
from .forms import ChatRoomForm, InterestForm, LoginForm, PhotoForm, SettingsForm, SignUpForm, VerifyCredentialsForm
from .queries import get_users_nearby

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
        return JsonResponse({ "token": token.key })

class DashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # receive the page number provided in the URL
        page = int(kwargs.get('page', 1))

        # get the users nearby this user
        latitude = float(request.user.latitude)
        longitude = float(request.user.longitude)
        max_distance_km = 10000
        users = get_users_nearby(latitude, longitude, max_distance_km).exclude(email=request.user.email)

        # receive the users of this page
        users_per_page = 10
        start_of_page = (page - 1) * users_per_page
        end_of_page = page * users_per_page
        users_page = users[start_of_page : end_of_page]

        # sort the users by best match to this user
        serializer = UserSerializer.MatchSerializer(users_page, context={ "user": request.user }, many=True)
        sorted_users = sorted(serializer.data, key=lambda user : user["match"], reverse=True)
        return JsonResponse({ "total_profiles": users.count(), "profiles_per_page": users_per_page, "profiles": sorted_users })

class ProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # receive the user of the profile id provided in the URL
        user_id = int(kwargs.get('id', 0))
        user = User.objects.filter(id=user_id).first()
        photos = Photo.objects.filter(user=user)

        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        # serialize the user and similarity between the logged-in user and the requested user
        user_serializer = UserSerializer.MatchSerializer(user, context={ "user": request.user })
        photos_serializer = PhotoSerializer(photos, many=True)

        return JsonResponse({ **user_serializer.data, "photos": photos_serializer.data })

    class SettingsView(APIView):
        permission_classes = [permissions.IsAuthenticated]
        
        def get(self, request):
            photos = Photo.objects.filter(user=request.user)

            # serialize this user and its photos
            user_serializer = UserSerializer(request.user)
            photos_serializer = PhotoSerializer(photos, many=True)

            return JsonResponse({ **user_serializer.data, "photos": photos_serializer.data })

        def put(self, request):
            settings_form = SettingsForm(request.data, request=request)

            if not settings_form.is_valid():
                return Response(settings_form.errors, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

            user = settings_form.save()
            user_serializer = UserSerializer(user)
            return JsonResponse(user_serializer.data)

        def delete(self, request):
            request.user.delete()
            return Response()

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
            recent_chat = room.chats[-1] if len(room.chats) > 0 else None

            if not recent_chat:
                # there exists no chats between the users, so don't append this message
                continue
            
            # attributes to showcase for this recent message based on who the sender of the message was
            message = recent_chat["message"]
            recent_chat["message"] = "You: " + message if recent_chat["id"] == request.user.id else message
            
            # make this user anonymous if the chat room is anonymous
            other_user = room.user_B if request.user == room.user_A else room.user_A
            serializer = UserSerializer.AnonymousSerializer(other_user, context={ "anonymous": room.anonymous })

            messages.append({ **serializer.data, "id": room.id, "message": recent_chat["message"] })
        
        return Response(messages)

    def post(self, request):
        chat_room_form = ChatRoomForm(request.data)
        
        if not chat_room_form.is_valid():
            return Response(status=HTTP_412_PRECONDITION_FAILED)
        
        # receive the user of the user that this user wants to chat with
        user_id = chat_room_form.cleaned_data["profile_id"]
        user = User.objects.filter(id=user_id).first()

        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        # check if a chat room already exists between the users
        chat_filter = (Q(user_A=request.user) & Q(user_B=user)) | (Q(user_A=user) & Q(user_B=request.user))
        room = ChatRoom.objects.filter(chat_filter).first()

        if not room:
            # create a new chat room between the other user and this user
            room = ChatRoom.objects.create(user_A=request.user, user_B=user)
            serializer = ChatRoomSerializer(room)
            return JsonResponse(serializer.data, status=status.HTTP_201_CREATED)

        serializer = ChatRoomSerializer(room)
        return JsonResponse(serializer.data)

    class ChatRoomView(APIView):
        permission_classes = [permissions.IsAuthenticated]

        def get(self, request, *args, **kwargs):
            # receive the chat room of the chat room id provided in the URL
            room_id = int(kwargs.get('id', 0))
            room = ChatRoom.objects.filter(id=room_id).first()

            # receive the chats (in reverse order) for the chat room page provided in the URL
            page = int(kwargs.get('page', 1))
            total_chats = len(room.chats)
            chats_per_page = 20
            start_of_page = total_chats - ((page) * chats_per_page)
            end_of_page = total_chats - ((page - 1) * chats_per_page)
            chats = room.chats[start_of_page if start_of_page > 0 else 0: end_of_page if end_of_page > 0 else 0]

            # receive the other user
            user = room.user_B if request.user == room.user_A else room.user_A

            # make these users anonymous if the chat room is still anonymous
            my_user_serializer = UserSerializer.AnonymousSerializer(request.user, context={ "anonymous": False })
            other_user_serializer = UserSerializer.AnonymousSerializer(user, context={ "anonymous": room.anonymous })

            return JsonResponse({ "total_chats": total_chats, "chats_per_page": chats_per_page, "me": my_user_serializer.data, "other": other_user_serializer.data, "chats": chats })


class LogoutView(APIView):
    def post(self, request):
        logout(request)
        return Response()