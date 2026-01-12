from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ClassificationJobViewSet, ClassificationResultViewSet, ClassifyViewSet

router = DefaultRouter()
router.register(r'jobs', ClassificationJobViewSet, basename='classification-jobs')
router.register(r'results', ClassificationResultViewSet, basename='classification-results')
router.register(r'classify', ClassifyViewSet, basename='classify')

urlpatterns = [
    path('', include(router.urls)),
]
