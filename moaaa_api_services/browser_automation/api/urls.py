from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import Browser_automationViewSet

router = DefaultRouter()
router.register(r'browser_automation', Browser_automationViewSet, basename='browser_automation')

urlpatterns = [
    path('', include(router.urls)),
]
