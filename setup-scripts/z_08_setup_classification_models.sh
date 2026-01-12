#!/bin/bash

# =============================================================================
# z_08_setup_classification_models.sh
# Creates models for document_classification app
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 8: Creating Classification Models"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_PATH="$PROJECT_ROOT/moaaa_api_services/document_classification"

echo "App path: $APP_PATH"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: document_classification app not found"
    exit 1
fi

# =============================================================================
# Create models.py
# =============================================================================
echo "Creating models.py..."
cat > "$APP_PATH/models.py" << 'EOF'
from django.db import models
from django.utils import timezone
import uuid


class ClassificationJob(models.Model):
    """
    Represents a classification job that processes one or more applications.
    One job can classify documents from multiple merchant applications.
    """
    
    class Status(models.TextChoices):
        PENDING = 'PENDING', 'Pending'
        IN_PROGRESS = 'IN_PROGRESS', 'In Progress'
        COMPLETED = 'COMPLETED', 'Completed'
        FAILED = 'FAILED', 'Failed'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Job metadata
    name = models.CharField(max_length=255, blank=True)
    description = models.TextField(blank=True)
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING
    )
    
    # Processing info
    total_documents = models.IntegerField(default=0)
    processed_documents = models.IntegerField(default=0)
    failed_documents = models.IntegerField(default=0)
    
    # Error tracking
    error_message = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Created by (for audit)
    created_by = models.CharField(max_length=255, blank=True)
    
    class Meta:
        db_table = 'classification_job'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"ClassificationJob({self.id}) - {self.status}"
    
    def start(self):
        self.status = self.Status.IN_PROGRESS
        self.started_at = timezone.now()
        self.save()
    
    def complete(self):
        self.status = self.Status.COMPLETED
        self.completed_at = timezone.now()
        self.save()
    
    def fail(self, error_message: str):
        self.status = self.Status.FAILED
        self.error_message = error_message
        self.completed_at = timezone.now()
        self.save()


class ClassificationResult(models.Model):
    """
    Represents a classification result for a single document.
    Multiple results can exist per document (different runs).
    Admin/Merchant can activate/deactivate results.
    """
    
    class DocumentType(models.TextChoices):
        BUSINESS_LICENSE = 'BUSINESS_LICENSE', 'Business License'
        BANK_STATEMENT = 'BANK_STATEMENT', 'Bank Statement'
        VOIDED_CHECK = 'VOIDED_CHECK', 'Voided Check'
        TAX_RETURN = 'TAX_RETURN', 'Tax Return'
        DRIVERS_LICENSE = 'DRIVERS_LICENSE', 'Drivers License'
        ARTICLES_OF_INCORPORATION = 'ARTICLES_OF_INCORPORATION', 'Articles of Incorporation'
        OTHER = 'OTHER', 'Other'
        UNKNOWN = 'UNKNOWN', 'Unknown'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relationships
    job = models.ForeignKey(
        ClassificationJob,
        on_delete=models.CASCADE,
        related_name='results'
    )
    
    # Application reference (string for now, FK to application_profile later)
    application_id = models.CharField(max_length=255)
    
    # Document info
    document_s3_bucket = models.CharField(max_length=255)
    document_s3_key = models.CharField(max_length=1024)
    document_filename = models.CharField(max_length=255)
    
    # Classification results
    document_type = models.CharField(
        max_length=50,
        choices=DocumentType.choices,
        default=DocumentType.UNKNOWN
    )
    confidence_score = models.FloatField(default=0.0)
    
    # Raw response from Bedrock
    raw_response = models.JSONField(default=dict, blank=True)
    
    # Status flags
    is_active = models.BooleanField(default=True)
    requires_review = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Audit
    created_by = models.CharField(max_length=255, blank=True)
    deactivated_at = models.DateTimeField(null=True, blank=True)
    deactivated_by = models.CharField(max_length=255, blank=True)
    
    class Meta:
        db_table = 'classification_result'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"ClassificationResult({self.document_type}, {self.confidence_score:.2%})"
    
    def deactivate(self, user: str = ''):
        self.is_active = False
        self.deactivated_at = timezone.now()
        self.deactivated_by = user
        self.save()
    
    def activate(self):
        self.is_active = True
        self.deactivated_at = None
        self.deactivated_by = ''
        self.save()
EOF

echo "Created models.py"

# =============================================================================
# Create admin.py
# =============================================================================
echo "Creating admin.py..."
cat > "$APP_PATH/admin.py" << 'EOF'
from django.contrib import admin
from .models import ClassificationJob, ClassificationResult


@admin.register(ClassificationJob)
class ClassificationJobAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'name', 'status', 'total_documents', 
        'processed_documents', 'failed_documents', 'created_at'
    ]
    list_filter = ['status', 'created_at']
    search_fields = ['id', 'name', 'description']
    readonly_fields = ['id', 'created_at', 'updated_at', 'started_at', 'completed_at']
    
    fieldsets = (
        ('Job Info', {
            'fields': ('id', 'name', 'description', 'status')
        }),
        ('Progress', {
            'fields': ('total_documents', 'processed_documents', 'failed_documents')
        }),
        ('Error', {
            'fields': ('error_message',),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at', 'started_at', 'completed_at'),
            'classes': ('collapse',)
        }),
        ('Audit', {
            'fields': ('created_by',),
            'classes': ('collapse',)
        }),
    )


@admin.register(ClassificationResult)
class ClassificationResultAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'job', 'application_id', 'document_type', 
        'confidence_score', 'is_active', 'requires_review', 'created_at'
    ]
    list_filter = ['document_type', 'is_active', 'requires_review', 'created_at']
    search_fields = ['id', 'application_id', 'document_filename']
    readonly_fields = ['id', 'created_at', 'updated_at']
    
    fieldsets = (
        ('Result Info', {
            'fields': ('id', 'job', 'application_id')
        }),
        ('Document', {
            'fields': ('document_s3_bucket', 'document_s3_key', 'document_filename')
        }),
        ('Classification', {
            'fields': ('document_type', 'confidence_score', 'requires_review')
        }),
        ('Status', {
            'fields': ('is_active', 'deactivated_at', 'deactivated_by')
        }),
        ('Raw Response', {
            'fields': ('raw_response',),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
EOF

echo "Created admin.py"

echo ""
echo "=========================================="
echo "Classification models created!"
echo "=========================================="
echo ""
echo "Models created:"
echo "  - ClassificationJob (one job -> many applications)"
echo "  - ClassificationResult (multiple active results allowed)"
echo ""
echo "Next steps:"
echo "  1. npm run django:makemigrations"
echo "  2. npm run django:migrate"
echo "  3. npm run django:createsuperuser"
echo "  4. npm run django:runserver"
echo "  5. Visit http://127.0.0.1:8000/admin/"
echo ""