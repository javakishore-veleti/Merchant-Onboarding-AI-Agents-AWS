from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import Application_profileViewSet

router = DefaultRouter()
router.register(r'application_profile', Application_profileViewSet, basename='application_profile')

urlpatterns = [
    path('', include(router.urls)),
]
