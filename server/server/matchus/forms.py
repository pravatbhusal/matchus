from django import forms
from django.contrib.auth import authenticate, login
from .models import default_profile_photo, User, Photo

class RequestForm(forms.Form):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop('request', None)
        super(RequestForm, self).__init__(*args, **kwargs)

class VerifyCredentialsForm(forms.Form):
    google_user_id = forms.CharField(required=False, max_length=128)
    email = forms.EmailField(required=True, min_length=4, max_length=128)
    password = forms.CharField(required=True, min_length=4, max_length=128, error_messages={
        "min_length": "The password is not strong enough."
    })

    def clean_email(self):
        email = self.data['email'].lower()

        account_exists = User.objects.filter(email=email).exists()
        if account_exists:
            # account already exists for this email, so return a conflicted response
            raise forms.ValidationError(f"User already exists with the email {email}.")
            
        return email

class SignUpForm(RequestForm, VerifyCredentialsForm):
    name = forms.CharField(required=True, max_length=128)
    interests = forms.JSONField(required=True, error_messages={
        "required": "Please input enough interests."
    })
    biography = forms.CharField(required=True, error_messages={
        "required": "Please input a biography."
    })
    location = forms.CharField(required=True, max_length=128, error_messages={
        "required": "Please input a location."
    })
    latitude = forms.DecimalField(required=True)
    longitude = forms.DecimalField(required=True)

    def save(self):
        """
        Creates a user with the provided form information.
        """

        user = User.objects.create_user(email=self.cleaned_data['email'], password=self.cleaned_data['password'])
        user.google_user_id = self.cleaned_data['google_user_id']
        user.name = self.cleaned_data['name']
        user.interests = self.cleaned_data['interests']
        user.biography = self.cleaned_data["biography"]
        user.location = self.cleaned_data['location']
        user.latitude = self.cleaned_data['latitude']
        user.longitude = self.cleaned_data['longitude']
        user.profile_photo = default_profile_photo
        user.save()
        login(self.request, user)
        return user

class LoginForm(RequestForm, forms.Form):
    google_user_id = forms.CharField(required=False, max_length=128)
    email = forms.EmailField(required=True, min_length=4, max_length=128)
    password = forms.CharField(required=True, min_length=4, max_length=128, error_messages={
        "min_length": "The password is not strong enough."
    })

    def clean(self):
        google_user_id = self.data['google_user_id']
        email = self.data['email'].lower()

        user = None
        if bool(google_user_id):
            # login using Google OAuth
            user = User.objects.filter(email=email, google_user_id=google_user_id).first()
        else:
            # login using the provided password
            password = self.data['password']
            user = authenticate(self.request, email=email, password=password)

        if user is None:
            # the authentication failed because the email and password combination was not found
            raise forms.ValidationError(f"The email and password credentials were not found.")

        self.user = user
        return user

    def save(self):
        """
        Starts the user's session.
        """

        login(self.request, self.user)
        return self.user

class SettingsForm(RequestForm):
    email = forms.EmailField(required=False, min_length=4, max_length=128)
    old_password = forms.CharField(required=False, min_length=4, max_length=128)
    password = forms.CharField(required=False, min_length=4, max_length=128)
    confirm_password = forms.CharField(required=False, min_length=4, max_length=128)
    name = forms.CharField(required=False, max_length=128)
    interests = forms.JSONField(required=False)
    biography = forms.CharField(required=False)
    location = forms.CharField(required=False, max_length=128)
    latitude = forms.DecimalField(required=False)
    longitude = forms.DecimalField(required=False)

    def clean_email(self):
        if 'email' not in self.data:
            return None

        email = self.data['email'].lower()

        account_exists = User.objects.filter(email=email).exists()
        if account_exists:
            # account already exists for this email, so return a conflicted response
            raise forms.ValidationError(f"User already exists with the email {email}.")
            
        return email

    def clean_password(self):
        if 'password' not in self.data:
            return None

        if 'old_password' not in self.data or 'confirm_password' not in self.data:
            raise forms.ValidationError(f"Please input all of the password fields.")

        old_password = self.data['old_password']
        password = self.data['password']
        confirm_password = self.data['confirm_password']

        if password != confirm_password:
            raise forms.ValidationError(f"The two passwords do not match.")

        # attempt to login this user to verify if the provided password is correct
        user = authenticate(self.request, email=self.request.user.email, password=old_password)
        if not user:
            raise forms.ValidationError(f"The old password is incorrect.")

        return password

    def save(self):
        """
        Updates a user with the provided form information.
        """

        for prop in self.cleaned_data:
            if getattr(self.request.user, prop, False):
                if bool(self.cleaned_data[prop]):
                    # update this property in the user since the user inputted a new property
                    setattr(self.request.user, prop, self.cleaned_data[prop])

        self.request.user.save()
        return self.request.user

class PhotoForm(forms.Form):
    photo = forms.ImageField(required=True, error_messages={
        "required": "Please upload a photo."
    })

class InterestForm(forms.Form):
    interest = forms.CharField(required=True, max_length=256, error_messages={
        "required": "Please enter an interest."
    })
    
class ChatRoomForm(forms.Form):
    profile_id = forms.IntegerField(required=True, error_messages={
        "required": "Please enter a profile id."
    })

