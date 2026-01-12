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
