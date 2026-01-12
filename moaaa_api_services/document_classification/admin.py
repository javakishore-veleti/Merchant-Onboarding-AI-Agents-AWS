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
