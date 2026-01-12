from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import Support_agentViewSet

router = DefaultRouter()
router.register(r'support_agent', Support_agentViewSet, basename='support_agent')

urlpatterns = [
    path('', include(router.urls)),
]
