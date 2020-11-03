from django.urls import path, include
from . import views

urlpatterns = [
    path('verify-credentials/', views.VerifyCredentialsView.as_view()),
    path('signup/', views.SignUpView.as_view()),
    path('login/', views.LoginView.as_view()),
    path('profile/<int:id>', views.ProfileView.as_view()),
    path('logout/', views.LogoutView.as_view()),
]