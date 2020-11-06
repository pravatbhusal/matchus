from channels.generic.websocket import AsyncWebsocketConsumer
from asgiref.sync import sync_to_async
from matchus.models import ChatRoom, User
from rest_framework.authtoken.models import Token
import json

class ChatRoomConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        room_id = self.scope['url_route']['kwargs']['id']
        self.room_group_name = 'chat_%s' % str(room_id)
        self.chat_room = await sync_to_async(ChatRoom.objects.get)(id=room_id)

        # join this chat room
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        # leave the chat room
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        json_data = json.loads(text_data)
        token = json_data['token']
        token = await sync_to_async(Token.objects.get)(key=token)

        # receive the user's id based on the token
        def get_user_id():
            return token.user.id
        user_id = await sync_to_async(get_user_id)()

        is_identity_request = bool("request" in json_data and json_data["request"])
        message = ""
        if is_identity_request:
            message = "Anonymous would like to reveal both of your profiles. Type ACCEPT or something else to deny."

            # set the user to request the identity from
            def set_identity_request():
                user_identity_from = self.chat_room.user_A if token.user != self.chat_room.user_A else self.chat_room.user_B
                self.chat_room.request_identity_from = user_identity_from
                self.chat_room.save()
            await sync_to_async(set_identity_request)()
        else:
            message = json_data['message']

            # if an identity request exists, then check if the user accepted the identity request
            def check_identity_request():
                if self.chat_room.request_identity_from and token.user != self.chat_room.request_identity_from:
                    self.chat_room.request_identity_from = None

                    # the chat room is no longer anonymous if the requested user accepted the request
                    self.chat_room.anonymous = not (message == "ACCEPT")
                    self.chat_room.save()
            await sync_to_async(check_identity_request)()

        # check if the chat room is still anonymous
        def get_anonymous():
            return bool(self.chat_room.anonymous)
        anonymous = await sync_to_async(get_anonymous)()

        # add this message into the chat room's model
        chat = { "id": user_id, "message": message, "anonymous": anonymous, "request": is_identity_request }
        def add_chat():
            self.chat_room.chats.append(chat)
            self.chat_room.save()
        await sync_to_async(add_chat)()

        # send message to chat room
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'chat': chat
            }
        )

    async def chat_message(self, event):
        chat = event['chat']

        # send the chat message back to the client
        await self.send(text_data=json.dumps(chat))