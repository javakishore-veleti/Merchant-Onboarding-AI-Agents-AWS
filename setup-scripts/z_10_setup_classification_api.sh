#!/bin/bash

# =============================================================================
# z_10_setup_classification_api.sh
# Creates REST API for document classification
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 10: Creating Classification API"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_PATH="$PROJECT_ROOT/moaaa_api_services/document_classification"
API_PATH="$APP_PATH/api"

echo "API path: $API_PATH"

# =============================================================================
# Create api/serializers.py
# =============================================================================
echo "Creating api/serializers.py..."
cat > "$API_PATH/serializers.py" << 'EOF'
from rest_framework import serializers
from ..models import ClassificationJob, ClassificationResult


class ClassificationResultSerializer(serializers.ModelSerializer):
    """Serializer for ClassificationResult."""
    
    class Meta:
        model = ClassificationResult
        fields = [
            'id',
            'job',
            'application_id',
            'document_s3_bucket',
            'document_s3_key',
            'document_filename',
            'document_type',
            'confidence_score',
            'is_active',
            'requires_review',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ClassificationJobSerializer(serializers.ModelSerializer):
    """Serializer for ClassificationJob."""
    
    results = ClassificationResultSerializer(many=True, read_only=True)
    
    class Meta:
        model = ClassificationJob
        fields = [
            'id',
            'name',
            'description',
            'status',
            'total_documents',
            'processed_documents',
            'failed_documents',
            'error_message',
            'created_at',
            'updated_at',
            'started_at',
            'completed_at',
            'results',
        ]
        read_only_fields = [
            'id', 'status', 'total_documents', 'processed_documents',
            'failed_documents', 'error_message', 'created_at', 'updated_at',
            'started_at', 'completed_at'
        ]


class ClassifyDocumentRequestSerializer(serializers.Serializer):
    """Request serializer for classifying a single document."""
    
    s3_bucket = serializers.CharField(max_length=255)
    s3_key = serializers.CharField(max_length=1024)
    filename = serializers.CharField(max_length=255)
    application_id = serializers.CharField(max_length=255)


class ClassifyBatchRequestSerializer(serializers.Serializer):
    """Request serializer for batch classification."""
    
    documents = ClassifyDocumentRequestSerializer(many=True)
    job_name = serializers.CharField(max_length=255, required=False, default='')
    job_description = serializers.CharField(required=False, default='')


class ClassifyDocumentResponseSerializer(serializers.Serializer):
    """Response serializer for classification result."""
    
    document_type = serializers.CharField()
    confidence_score = serializers.FloatField()
    requires_review = serializers.BooleanField()
    result_id = serializers.UUIDField()


class ActivateDeactivateSerializer(serializers.Serializer):
    """Request serializer for activate/deactivate actions."""
    
    user = serializers.CharField(max_length=255, required=False, default='')
EOF

echo "Created api/serializers.py"

# =============================================================================
# Create api/views.py
# =============================================================================
echo "Creating api/views.py..."
cat > "$API_PATH/views.py" << 'EOF'
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from ..models import ClassificationJob, ClassificationResult
from ..ai_ml import BedrockClassifier, ClassificationInput
from .serializers import (
    ClassificationJobSerializer,
    ClassificationResultSerializer,
    ClassifyDocumentRequestSerializer,
    ClassifyBatchRequestSerializer,
    ClassifyDocumentResponseSerializer,
    ActivateDeactivateSerializer,
)


class ClassificationJobViewSet(viewsets.ModelViewSet):
    """
    ViewSet for ClassificationJob.
    
    Endpoints:
        GET /api/classification/jobs/ - List all jobs
        POST /api/classification/jobs/ - Create a job
        GET /api/classification/jobs/{id}/ - Get job details
        DELETE /api/classification/jobs/{id}/ - Delete a job
    """
    
    queryset = ClassificationJob.objects.all()
    serializer_class = ClassificationJobSerializer


class ClassificationResultViewSet(viewsets.ModelViewSet):
    """
    ViewSet for ClassificationResult.
    
    Endpoints:
        GET /api/classification/results/ - List all results
        GET /api/classification/results/{id}/ - Get result details
        POST /api/classification/results/{id}/activate/ - Activate result
        POST /api/classification/results/{id}/deactivate/ - Deactivate result
    """
    
    queryset = ClassificationResult.objects.all()
    serializer_class = ClassificationResultSerializer
    
    @action(detail=True, methods=['post'])
    def activate(self, request, pk=None):
        """Activate a classification result."""
        result = self.get_object()
        result.activate()
        return Response({
            'status': 'activated',
            'id': str(result.id),
            'is_active': result.is_active
        })
    
    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        """Deactivate a classification result."""
        serializer = ActivateDeactivateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        result = self.get_object()
        result.deactivate(user=serializer.validated_data.get('user', ''))
        
        return Response({
            'status': 'deactivated',
            'id': str(result.id),
            'is_active': result.is_active
        })


class ClassifyViewSet(viewsets.ViewSet):
    """
    ViewSet for document classification operations.
    
    Endpoints:
        POST /api/classification/classify/ - Classify a single document
        POST /api/classification/classify/batch/ - Classify multiple documents
    """
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.classifier = BedrockClassifier()
    
    def create(self, request):
        """
        Classify a single document.
        
        Request:
            {
                "s3_bucket": "my-bucket",
                "s3_key": "documents/license.pdf",
                "filename": "license.pdf",
                "application_id": "app-001"
            }
        
        Response:
            {
                "document_type": "BUSINESS_LICENSE",
                "confidence_score": 0.95,
                "requires_review": false,
                "result_id": "uuid"
            }
        """
        serializer = ClassifyDocumentRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        
        # Create a job for this single classification
        job = ClassificationJob.objects.create(
            name=f"Single classification: {data['filename']}",
            total_documents=1,
            created_by=request.user.username if request.user.is_authenticated else 'anonymous'
        )
        job.start()
        
        try:
            # Create input
            input_data = ClassificationInput(
                s3_bucket=data['s3_bucket'],
                s3_key=data['s3_key'],
                filename=data['filename'],
                application_id=data['application_id']
            )
            
            # Classify
            output = self.classifier.classify(input_data)
            
            # Save result
            result = ClassificationResult.objects.create(
                job=job,
                application_id=data['application_id'],
                document_s3_bucket=data['s3_bucket'],
                document_s3_key=data['s3_key'],
                document_filename=data['filename'],
                document_type=output.document_type,
                confidence_score=output.confidence_score,
                requires_review=output.requires_review,
                raw_response=output.raw_response,
                created_by=request.user.username if request.user.is_authenticated else 'anonymous'
            )
            
            # Update job
            job.processed_documents = 1
            job.complete()
            
            # Return response
            response_data = {
                'document_type': output.document_type,
                'confidence_score': output.confidence_score,
                'requires_review': output.requires_review,
                'result_id': str(result.id),
                'job_id': str(job.id)
            }
            
            return Response(response_data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            job.fail(str(e))
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['post'])
    def batch(self, request):
        """
        Classify multiple documents in a batch.
        
        Request:
            {
                "job_name": "Batch classification",
                "job_description": "Optional description",
                "documents": [
                    {
                        "s3_bucket": "my-bucket",
                        "s3_key": "documents/license.pdf",
                        "filename": "license.pdf",
                        "application_id": "app-001"
                    },
                    ...
                ]
            }
        
        Response:
            {
                "job_id": "uuid",
                "status": "COMPLETED",
                "total": 3,
                "processed": 3,
                "failed": 0,
                "results": [...]
            }
        """
        serializer = ClassifyBatchRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        
        documents = data['documents']
        
        # Create job
        job = ClassificationJob.objects.create(
            name=data.get('job_name') or f"Batch classification: {len(documents)} documents",
            description=data.get('job_description', ''),
            total_documents=len(documents),
            created_by=request.user.username if request.user.is_authenticated else 'anonymous'
        )
        job.start()
        
        results = []
        failed = 0
        
        for doc in documents:
            try:
                # Create input
                input_data = ClassificationInput(
                    s3_bucket=doc['s3_bucket'],
                    s3_key=doc['s3_key'],
                    filename=doc['filename'],
                    application_id=doc['application_id']
                )
                
                # Classify
                output = self.classifier.classify(input_data)
                
                # Save result
                result = ClassificationResult.objects.create(
                    job=job,
                    application_id=doc['application_id'],
                    document_s3_bucket=doc['s3_bucket'],
                    document_s3_key=doc['s3_key'],
                    document_filename=doc['filename'],
                    document_type=output.document_type,
                    confidence_score=output.confidence_score,
                    requires_review=output.requires_review,
                    raw_response=output.raw_response,
                    created_by=request.user.username if request.user.is_authenticated else 'anonymous'
                )
                
                results.append({
                    'result_id': str(result.id),
                    'filename': doc['filename'],
                    'document_type': output.document_type,
                    'confidence_score': output.confidence_score,
                    'requires_review': output.requires_review
                })
                
            except Exception as e:
                failed += 1
                results.append({
                    'filename': doc['filename'],
                    'error': str(e)
                })
        
        # Update job
        job.processed_documents = len(documents) - failed
        job.failed_documents = failed
        
        if failed == len(documents):
            job.fail("All documents failed to process")
        else:
            job.complete()
        
        return Response({
            'job_id': str(job.id),
            'status': job.status,
            'total': len(documents),
            'processed': job.processed_documents,
            'failed': job.failed_documents,
            'results': results
        }, status=status.HTTP_201_CREATED)
EOF

echo "Created api/views.py"

# =============================================================================
# Create api/urls.py
# =============================================================================
echo "Creating api/urls.py..."
cat > "$API_PATH/urls.py" << 'EOF'
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
EOF

echo "Created api/urls.py"

# =============================================================================
# Update main urls.py to include classification API
# =============================================================================
echo "Updating main urls.py..."
MAIN_URLS="$PROJECT_ROOT/moaaa_api_services/moaaa_api_services/urls.py"

cat > "$MAIN_URLS" << 'EOF'
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
EOF

echo "Updated main urls.py"

echo ""
echo "=========================================="
echo "Classification API created!"
echo "=========================================="
echo ""
echo "Endpoints:"
echo ""
echo "  GET  /                                    - API root"
echo "  GET  /api/classification/jobs/            - List jobs"
echo "  POST /api/classification/jobs/            - Create job"
echo "  GET  /api/classification/jobs/{id}/       - Get job"
echo ""
echo "  GET  /api/classification/results/         - List results"
echo "  GET  /api/classification/results/{id}/    - Get result"
echo "  POST /api/classification/results/{id}/activate/   - Activate"
echo "  POST /api/classification/results/{id}/deactivate/ - Deactivate"
echo ""
echo "  POST /api/classification/classify/        - Classify single document"
echo "  POST /api/classification/classify/batch/  - Classify batch"
echo ""
echo "Next steps:"
echo "  1. npm run django:runserver"
echo "  2. Visit http://127.0.0.1:8000/"
echo "  3. Test with: curl http://127.0.0.1:8000/api/classification/jobs/"
echo ""