from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from . import views

urlpatterns = [
    path('verify-credentials', views.VerifyCredentialsView.as_view()),
    path('signup', views.SignUpView.as_view()),
    path('login', views.LoginView.as_view()),
    path('profile/<int:id>', views.ProfileView.as_view()),
    path('profile/profile-photo', views.ProfileView.ProfilePhotoView.as_view()),
    path('profile/photos', views.ProfileView.PhotosView.as_view()),
    path('profile/photos/<str:name>', views.ProfileView.PhotosView.as_view()),
    path('chats', views.ChatView.as_view()),
    path('chats/<int:id>', views.ChatView.ChatProfileView.as_view()),
    path('logout', views.LogoutView.as_view()),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)