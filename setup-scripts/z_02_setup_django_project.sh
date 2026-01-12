#!/bin/bash

# =============================================================================
# z_02_setup_django_project.sh
# Creates Django project: moaaa_api_services
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 2: Creating Django Project"
echo "=========================================="

# Define paths
VENV_PATH="$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DJANGO_PROJECT_NAME="moaaa_api_services"
DJANGO_PROJECT_PATH="$PROJECT_ROOT/$DJANGO_PROJECT_NAME"

echo "Project root: $PROJECT_ROOT"
echo "Django project: $DJANGO_PROJECT_PATH"

# Check if venv exists
if [ ! -d "$VENV_PATH" ]; then
    echo "ERROR: Virtual environment not found at $VENV_PATH"
    echo "Please run z_01_setup_venv.sh first"
    exit 1
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# Install Django if not installed
echo "Installing Django..."
pip install --upgrade pip
pip install django

echo "Django version: $(django-admin --version)"

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if Django project already exists
if [ -d "$DJANGO_PROJECT_PATH" ]; then
    echo "Django project already exists at: $DJANGO_PROJECT_PATH"
    read -p "Do you want to recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$DJANGO_PROJECT_PATH"
        echo "Removed existing Django project"
    else
        echo "Keeping existing Django project"
        exit 0
    fi
fi

# Create Django project
echo "Creating Django project: $DJANGO_PROJECT_NAME"
django-admin startproject "$DJANGO_PROJECT_NAME"

# Create requirements.txt
echo "Creating requirements.txt..."
cat > "$DJANGO_PROJECT_PATH/requirements.txt" << EOF
# Django
Django>=5.0,<6.0

# Django REST Framework
djangorestframework>=3.14,<4.0

# AWS SDK
boto3>=1.34,<2.0

# Environment variables
python-dotenv>=1.0,<2.0

# Database (PostgreSQL)
psycopg2-binary>=2.9,<3.0

# CORS headers
django-cors-headers>=4.3,<5.0

# Testing
pytest>=8.0,<9.0
pytest-django>=4.8,<5.0
EOF

# Install requirements
echo "Installing requirements..."
pip install -r "$DJANGO_PROJECT_PATH/requirements.txt"

echo ""
echo "=========================================="
echo "Django project created successfully!"
echo "=========================================="
echo ""
echo "Location: $DJANGO_PROJECT_PATH"
echo ""
echo "To verify, run:"
echo "  source $VENV_PATH/bin/activate"
echo "  cd $DJANGO_PROJECT_PATH"
echo "  python manage.py runserver"
echo ""
echo "Next step:"
echo "  ./setup-scripts/z_03_setup_domain_apps.sh"
echo ""