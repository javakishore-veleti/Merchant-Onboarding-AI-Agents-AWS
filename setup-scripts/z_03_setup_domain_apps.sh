#!/bin/bash

# =============================================================================
# z_03_setup_domain_apps.sh
# Creates Domain Apps: merchant_profile, application_profile
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 3: Creating Domain Apps"
echo "=========================================="

# Define paths
VENV_PATH="$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DJANGO_PROJECT_PATH="$PROJECT_ROOT/moaaa_api_services"

echo "Project root: $PROJECT_ROOT"
echo "Django project: $DJANGO_PROJECT_PATH"

# Check if Django project exists
if [ ! -d "$DJANGO_PROJECT_PATH" ]; then
    echo "ERROR: Django project not found at $DJANGO_PROJECT_PATH"
    echo "Please run z_02_setup_django_project.sh first"
    exit 1
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# Navigate to Django project
cd "$DJANGO_PROJECT_PATH"

# =============================================================================
# Function to capitalize first letter (macOS compatible)
# =============================================================================
capitalize() {
    echo "$(echo ${1:0:1} | tr '[:lower:]' '[:upper:]')${1:1}"
}

# =============================================================================
# Function to create app structure
# =============================================================================
create_app_structure() {
    local APP_NAME=$1
    echo ""
    echo "----------------------------------------"
    echo "Creating app: $APP_NAME"
    echo "----------------------------------------"

    # Create Django app if not exists
    if [ ! -d "$APP_NAME" ]; then
        python manage.py startapp "$APP_NAME"
        echo "Created Django app: $APP_NAME"
    else
        echo "App $APP_NAME already exists, updating structure..."
    fi

    # Create dao/interfaces/
    mkdir -p "$APP_NAME/dao/interfaces"
    touch "$APP_NAME/dao/__init__.py"
    touch "$APP_NAME/dao/interfaces/__init__.py"

    # Create dao/implementations/
    mkdir -p "$APP_NAME/dao/implementations"
    touch "$APP_NAME/dao/implementations/__init__.py"

    # Create core/interfaces/
    mkdir -p "$APP_NAME/core/interfaces"
    touch "$APP_NAME/core/__init__.py"
    touch "$APP_NAME/core/interfaces/__init__.py"

    # Create core/implementations/
    mkdir -p "$APP_NAME/core/implementations"
    touch "$APP_NAME/core/implementations/__init__.py"

    # Create api/
    mkdir -p "$APP_NAME/api"
    touch "$APP_NAME/api/__init__.py"

    # Create tests/
    mkdir -p "$APP_NAME/tests"
    touch "$APP_NAME/tests/__init__.py"

    echo "Created folder structure for: $APP_NAME"
}

# =============================================================================
# Function to create placeholder files
# =============================================================================
create_placeholder_files() {
    local APP_NAME=$1
    local APP_NAME_CAP=$(capitalize "$APP_NAME")

    # dao/interfaces/ placeholder
    if [ ! -f "$APP_NAME/dao/interfaces/${APP_NAME}_repository.py" ]; then
        cat > "$APP_NAME/dao/interfaces/${APP_NAME}_repository.py" << EOF
from abc import ABC, abstractmethod
from typing import List, Optional


class I${APP_NAME_CAP}Repository(ABC):
    """Abstract interface for ${APP_NAME} repository."""

    @abstractmethod
    def get_by_id(self, id: str) -> Optional[dict]:
        pass

    @abstractmethod
    def get_all(self) -> List[dict]:
        pass

    @abstractmethod
    def create(self, data: dict) -> dict:
        pass

    @abstractmethod
    def update(self, id: str, data: dict) -> Optional[dict]:
        pass

    @abstractmethod
    def delete(self, id: str) -> bool:
        pass
EOF
    fi

    # dao/implementations/ placeholder
    if [ ! -f "$APP_NAME/dao/implementations/${APP_NAME}_repository_impl.py" ]; then
        cat > "$APP_NAME/dao/implementations/${APP_NAME}_repository_impl.py" << EOF
from typing import List, Optional
from ..interfaces.${APP_NAME}_repository import I${APP_NAME_CAP}Repository
from ..models import *


class ${APP_NAME_CAP}RepositoryImpl(I${APP_NAME_CAP}Repository):
    """Concrete implementation of ${APP_NAME} repository."""

    def get_by_id(self, id: str) -> Optional[dict]:
        # TODO: Implement
        pass

    def get_all(self) -> List[dict]:
        # TODO: Implement
        pass

    def create(self, data: dict) -> dict:
        # TODO: Implement
        pass

    def update(self, id: str, data: dict) -> Optional[dict]:
        # TODO: Implement
        pass

    def delete(self, id: str) -> bool:
        # TODO: Implement
        pass
EOF
    fi

    # core/interfaces/ placeholder
    if [ ! -f "$APP_NAME/core/interfaces/${APP_NAME}_service.py" ]; then
        cat > "$APP_NAME/core/interfaces/${APP_NAME}_service.py" << EOF
from abc import ABC, abstractmethod
from typing import List, Optional


class I${APP_NAME_CAP}Service(ABC):
    """Abstract interface for ${APP_NAME} service."""

    @abstractmethod
    def get_by_id(self, id: str) -> Optional[dict]:
        pass

    @abstractmethod
    def get_all(self) -> List[dict]:
        pass

    @abstractmethod
    def create(self, data: dict) -> dict:
        pass

    @abstractmethod
    def update(self, id: str, data: dict) -> Optional[dict]:
        pass

    @abstractmethod
    def delete(self, id: str) -> bool:
        pass
EOF
    fi

    # core/implementations/ placeholder
    if [ ! -f "$APP_NAME/core/implementations/${APP_NAME}_service_impl.py" ]; then
        cat > "$APP_NAME/core/implementations/${APP_NAME}_service_impl.py" << EOF
from typing import List, Optional
from ..interfaces.${APP_NAME}_service import I${APP_NAME_CAP}Service
from ...dao.interfaces.${APP_NAME}_repository import I${APP_NAME_CAP}Repository


class ${APP_NAME_CAP}ServiceImpl(I${APP_NAME_CAP}Service):
    """Concrete implementation of ${APP_NAME} service."""

    def __init__(self, repository: I${APP_NAME_CAP}Repository):
        self.repository = repository

    def get_by_id(self, id: str) -> Optional[dict]:
        return self.repository.get_by_id(id)

    def get_all(self) -> List[dict]:
        return self.repository.get_all()

    def create(self, data: dict) -> dict:
        # TODO: Add business logic/validation
        return self.repository.create(data)

    def update(self, id: str, data: dict) -> Optional[dict]:
        # TODO: Add business logic/validation
        return self.repository.update(id, data)

    def delete(self, id: str) -> bool:
        return self.repository.delete(id)
EOF
    fi

    # api/views.py
    if [ ! -f "$APP_NAME/api/views.py" ]; then
        cat > "$APP_NAME/api/views.py" << EOF
from rest_framework import viewsets, status
from rest_framework.response import Response


class ${APP_NAME_CAP}ViewSet(viewsets.ViewSet):
    """API ViewSet for ${APP_NAME}."""

    def list(self, request):
        # TODO: Implement
        return Response([])

    def retrieve(self, request, pk=None):
        # TODO: Implement
        return Response({})

    def create(self, request):
        # TODO: Implement
        return Response({}, status=status.HTTP_201_CREATED)

    def update(self, request, pk=None):
        # TODO: Implement
        return Response({})

    def destroy(self, request, pk=None):
        # TODO: Implement
        return Response(status=status.HTTP_204_NO_CONTENT)
EOF
    fi

    # api/serializers.py
    if [ ! -f "$APP_NAME/api/serializers.py" ]; then
        cat > "$APP_NAME/api/serializers.py" << EOF
from rest_framework import serializers


# TODO: Add serializers for ${APP_NAME} models
EOF
    fi

    # api/urls.py
    if [ ! -f "$APP_NAME/api/urls.py" ]; then
        cat > "$APP_NAME/api/urls.py" << EOF
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ${APP_NAME_CAP}ViewSet

router = DefaultRouter()
router.register(r'${APP_NAME}', ${APP_NAME_CAP}ViewSet, basename='${APP_NAME}')

urlpatterns = [
    path('', include(router.urls)),
]
EOF
    fi

    echo "Created placeholder files for: $APP_NAME"
}

# =============================================================================
# Create Domain Apps
# =============================================================================

# App 1: merchant_profile
create_app_structure "merchant_profile"
create_placeholder_files "merchant_profile"

# App 2: application_profile
create_app_structure "application_profile"
create_placeholder_files "application_profile"

echo ""
echo "=========================================="
echo "Domain apps created successfully!"
echo "=========================================="
echo ""
echo "Apps created:"
echo "  - merchant_profile"
echo "  - application_profile"
echo ""
echo "Structure for each app:"
echo "  app_name/"
echo "  ├── models.py"
echo "  ├── admin.py"
echo "  ├── dao/"
echo "  │   ├── interfaces/"
echo "  │   └── implementations/"
echo "  ├── core/"
echo "  │   ├── interfaces/"
echo "  │   └── implementations/"
echo "  ├── api/"
echo "  │   ├── views.py"
echo "  │   ├── serializers.py"
echo "  │   └── urls.py"
echo "  └── tests/"
echo ""
echo "Next step:"
echo "  ./setup-scripts/z_04_setup_aiml_apps.sh"
echo ""