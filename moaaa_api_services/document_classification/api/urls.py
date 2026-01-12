from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import Document_classificationViewSet

router = DefaultRouter()
router.register(r'document_classification', Document_classificationViewSet, basename='document_classification')

urlpatterns = [
    path('', include(router.urls)),
]
