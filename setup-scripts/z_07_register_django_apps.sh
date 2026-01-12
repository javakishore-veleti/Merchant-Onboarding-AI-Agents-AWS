#!/bin/bash

# =============================================================================
# z_07_register_django_apps.sh
# Registers all apps in Django settings.py
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 7: Registering Django Apps"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SETTINGS_FILE="$PROJECT_ROOT/moaaa_api_services/moaaa_api_services/settings.py"

echo "Project root: $PROJECT_ROOT"
echo "Settings file: $SETTINGS_FILE"

# Check if settings.py exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "ERROR: settings.py not found at $SETTINGS_FILE"
    exit 1
fi

# Check if apps already registered
if grep -q "merchant_profile" "$SETTINGS_FILE"; then
    echo "Apps already registered in settings.py, skipping..."
    exit 0
fi

# Backup settings.py
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
echo "Created backup: $SETTINGS_FILE.backup"

# Replace INSTALLED_APPS section
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/INSTALLED_APPS = \[/INSTALLED_APPS = [\
    # Third-party apps\
    "rest_framework",\
    "corsheaders",\
    \
    # Domain apps\
    "merchant_profile",\
    "application_profile",\
    \
    # AI\/ML apps\
    "document_classification",\
    "document_extraction",\
    "support_agent",\
    "browser_automation",\
    \
    # Django default apps/' "$SETTINGS_FILE"
else
    # Linux
    sed -i 's/INSTALLED_APPS = \[/INSTALLED_APPS = [\n    # Third-party apps\n    "rest_framework",\n    "corsheaders",\n    \n    # Domain apps\n    "merchant_profile",\n    "application_profile",\n    \n    # AI\/ML apps\n    "document_classification",\n    "document_extraction",\n    "support_agent",\n    "browser_automation",\n    \n    # Django default apps/' "$SETTINGS_FILE"
fi

echo "Registered apps in INSTALLED_APPS"

# Add CORS middleware
if ! grep -q "corsheaders.middleware" "$SETTINGS_FILE"; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/"django.middleware.security.SecurityMiddleware",/"django.middleware.security.SecurityMiddleware",\
    "corsheaders.middleware.CorsMiddleware",/' "$SETTINGS_FILE"
    else
        sed -i 's/"django.middleware.security.SecurityMiddleware",/"django.middleware.security.SecurityMiddleware",\n    "corsheaders.middleware.CorsMiddleware",/' "$SETTINGS_FILE"
    fi
    echo "Added CORS middleware"
fi

# Add REST Framework and AWS settings at the end
cat >> "$SETTINGS_FILE" << 'EOF'


# =============================================================================
# Django REST Framework
# =============================================================================
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}


# =============================================================================
# CORS Settings
# =============================================================================
CORS_ALLOW_ALL_ORIGINS = True  # For development only


# =============================================================================
# AWS Settings
# =============================================================================
import os

AWS_PROFILE = os.environ.get('AWS_PROFILE', 'moaaa_api_services')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
EOF

echo "Added REST Framework and AWS settings"

echo ""
echo "=========================================="
echo "Django apps registered successfully!"
echo "=========================================="
echo ""
echo "Apps registered:"
echo "  - rest_framework"
echo "  - corsheaders"
echo "  - merchant_profile"
echo "  - application_profile"
echo "  - document_classification"
echo "  - document_extraction"
echo "  - support_agent"
echo "  - browser_automation"
echo ""
echo "Next steps:"
echo "  1. npm run django:makemigrations"
echo "  2. npm run django:migrate"
echo ""