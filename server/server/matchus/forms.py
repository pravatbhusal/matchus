from django import forms
from django.contrib.auth import authenticate, login
from .models import User

class VerifyCredentialsForm(forms.Form):
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

class SignUpForm(VerifyCredentialsForm):
    location = forms.CharField(required=True, max_length=128, error_messages={
        "required": "Please input a location field."
    })
    interests = forms.JSONField(required=True, error_messages={
        "required": "Please input interests fields."
    })

    def save(self):
        """
        Creates a user with the provided form information.
        """

        user = User.objects.create_user(email=self.cleaned_data['email'], password=self.cleaned_data['password'])
        user.location = self.cleaned_data['location']
        user.interests = self.cleaned_data['interests']
        user.save()
        return user

class LoginForm(forms.Form):
    email = forms.EmailField(required=True, min_length=4, max_length=128)
    password = forms.CharField(required=True, min_length=4, max_length=128, error_messages={
        "min_length": "The password is not strong enough."
    })

    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop('request', None)
        super(LoginForm, self).__init__(*args, **kwargs)

    def clean(self):
        email = self.data['email'].lower()
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

        
