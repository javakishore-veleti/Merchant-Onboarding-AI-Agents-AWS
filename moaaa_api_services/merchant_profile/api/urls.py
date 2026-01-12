from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import Merchant_profileViewSet

router = DefaultRouter()
router.register(r'merchant_profile', Merchant_profileViewSet, basename='merchant_profile')

urlpatterns = [
    path('', include(router.urls)),
]
