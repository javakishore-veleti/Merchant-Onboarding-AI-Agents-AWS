from django.contrib import admin
from django.urls import path, include
from rest_framework.response import Response
from rest_framework.decorators import api_view


@api_view(['GET'])
def api_root(request):
    """API root endpoint."""
    return Response({
        'message': 'Welcome to MOAAA API Services',
        'version': '1.0.0',
        'endpoints': {
            'admin': '/admin/',
            'classification': '/api/classification/',
        }
    })


urlpatterns = [
    path('', api_root, name='api-root'),
    path('admin/', admin.site.urls),
    path('api/classification/', include('document_classification.api.urls')),
]
