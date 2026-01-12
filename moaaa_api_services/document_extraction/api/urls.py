from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import Document_extractionViewSet

router = DefaultRouter()
router.register(r'document_extraction', Document_extractionViewSet, basename='document_extraction')

urlpatterns = [
    path('', include(router.urls)),
]
