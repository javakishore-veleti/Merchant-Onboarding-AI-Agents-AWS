#!/bin/bash

# =============================================================================
# z_02a_setup_package_json.sh
# Creates package.json for npm scripts as task runner
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 2a: Creating package.json"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGE_JSON_PATH="$PROJECT_ROOT/package.json"

echo "Project root: $PROJECT_ROOT"

# Check if package.json already exists
if [ -f "$PACKAGE_JSON_PATH" ]; then
    echo "package.json already exists at: $PACKAGE_JSON_PATH"
    read -p "Do you want to overwrite it? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing package.json"
        exit 0
    fi
fi

# Create package.json
echo "Creating package.json..."
cat > "$PACKAGE_JSON_PATH" << 'EOF'
{
  "name": "merchant-onboarding-ai-agents-aws",
  "version": "1.0.0",
  "description": "AI-powered merchant onboarding platform using Amazon Bedrock, AgentCore, and Nova Act",
  "private": true,
  "scripts": {
    "django:runserver": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py runserver",
    "django:runserver:8001": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py runserver 8001",
    "django:migrate": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py migrate",
    "django:makemigrations": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py makemigrations",
    "django:shell": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py shell",
    "django:createsuperuser": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py createsuperuser",
    "django:test": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py test",
    "pip:install": "$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/pip install -r moaaa_api_services/requirements.txt",
    "pip:freeze": "$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/pip freeze",
    "setup:venv": "./setup-scripts/z_01_setup_venv.sh",
    "setup:django": "./setup-scripts/z_02_setup_django_project.sh",
    "setup:package-json": "./setup-scripts/z_02a_setup_package_json.sh",
    "setup:domain-apps": "./setup-scripts/z_03_setup_domain_apps.sh",
    "setup:aiml-apps": "./setup-scripts/z_04_setup_aiml_apps.sh",
    "setup:root-files": "./setup-scripts/z_05_setup_root_files.sh",
    "setup:all": "npm run setup:venv && npm run setup:django && npm run setup:package-json && npm run setup:domain-apps && npm run setup:aiml-apps && npm run setup:root-files"
  },
  "author": "Kishore Veleti",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/javakishore-veleti/Merchant-Onboarding-AI-Agents-AWS.git"
  }
}
EOF

echo ""
echo "=========================================="
echo "package.json created successfully!"
echo "=========================================="
echo ""
echo "Location: $PACKAGE_JSON_PATH"
echo ""
echo "Available commands:"
echo "  npm run django:runserver     - Start Django server"
echo "  npm run django:migrate       - Run migrations"
echo "  npm run django:makemigrations - Create migrations"
echo "  npm run django:shell         - Django shell"
echo "  npm run pip:install          - Install requirements"
echo ""
echo "Next step:"
echo "  ./setup-scripts/z_03_setup_domain_apps.sh"
echo ""