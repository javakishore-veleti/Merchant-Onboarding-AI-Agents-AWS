#!/bin/bash

# =============================================================================
# z_06_update_aws_profile.sh
# Updates README.md and package.json with AWS profile configuration
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 6: Updating AWS Profile Configuration"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# =============================================================================
# Update README.md - Insert AWS Profile section after Prerequisites
# =============================================================================
echo "Updating README.md..."

# Check if AWS Profile section already exists
if grep -q "AWS Profile Setup" "$PROJECT_ROOT/README.md"; then
    echo "AWS Profile section already exists in README.md, skipping..."
else
    # Create temp file with AWS profile section
    cat > /tmp/aws_profile_section.txt << 'EOF'

### AWS Profile Setup

This project uses AWS profile `moaaa_api_services`. Set it up before running:

```bash
# Create AWS profile
aws configure --profile moaaa_api_services

# Enter when prompted:
# AWS Access Key ID: <your-access-key>
# AWS Secret Access Key: <your-secret-key>
# Default region name: us-east-1
# Default output format: json

# Verify profile
aws sts get-caller-identity --profile moaaa_api_services
```

The profile is read from `~/.aws/credentials` and `~/.aws/config`.
EOF

    # Insert after "- AWS Account with Bedrock access" line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' '/AWS Account with Bedrock access/r /tmp/aws_profile_section.txt' "$PROJECT_ROOT/README.md"
    else
        # Linux
        sed -i '/AWS Account with Bedrock access/r /tmp/aws_profile_section.txt' "$PROJECT_ROOT/README.md"
    fi
    
    rm /tmp/aws_profile_section.txt
    echo "Added AWS Profile section to README.md"
fi

# =============================================================================
# Update package.json - Add AWS commands
# =============================================================================
echo "Updating package.json..."

cat > "$PROJECT_ROOT/package.json" << 'EOF'
{
  "name": "merchant-onboarding-ai-agents-aws",
  "version": "1.0.0",
  "description": "AI-powered merchant onboarding platform using Amazon Bedrock, AgentCore, and Nova Act",
  "private": true,
  "config": {
    "aws_profile": "moaaa_api_services",
    "venv_path": "$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services"
  },
  "scripts": {
    "django:runserver": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py runserver",
    "django:runserver:8001": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py runserver 8001",
    "django:migrate": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py migrate",
    "django:makemigrations": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py makemigrations",
    "django:shell": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py shell",
    "django:createsuperuser": "cd moaaa_api_services && $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py createsuperuser",
    "django:test": "cd moaaa_api_services && AWS_PROFILE=moaaa_api_services $HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/python manage.py test",
    "pip:install": "$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/pip install -r moaaa_api_services/requirements.txt",
    "pip:freeze": "$HOME/runtime_data/delete_me_later/python_venvs/moaaa_api_services/bin/pip freeze",
    "aws:check-profile": "aws sts get-caller-identity --profile moaaa_api_services",
    "aws:bedrock-models": "aws bedrock list-foundation-models --profile moaaa_api_services --query 'modelSummaries[?contains(modelId, `anthropic`)].modelId'",
    "setup:venv": "./setup-scripts/z_01_setup_venv.sh",
    "setup:django": "./setup-scripts/z_02_setup_django_project.sh",
    "setup:package-json": "./setup-scripts/z_02a_setup_package_json.sh",
    "setup:domain-apps": "./setup-scripts/z_03_setup_domain_apps.sh",
    "setup:aiml-apps": "./setup-scripts/z_04_setup_aiml_apps.sh",
    "setup:root-files": "./setup-scripts/z_05_setup_root_files.sh",
    "setup:aws-profile": "./setup-scripts/z_06_update_aws_profile.sh",
    "setup:all": "npm run setup:venv && npm run setup:django && npm run setup:package-json && npm run setup:domain-apps && npm run setup:aiml-apps && npm run setup:root-files && npm run setup:aws-profile"
  },
  "author": "Kishore Veleti",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/javakishore-veleti/Merchant-Onboarding-AI-Agents-AWS.git"
  }
}
EOF

echo "Updated package.json with AWS commands"

echo ""
echo "=========================================="
echo "AWS Profile configuration updated!"
echo "=========================================="
echo ""
echo "New npm commands available:"
echo "  npm run aws:check-profile   - Verify AWS profile is configured"
echo "  npm run aws:bedrock-models  - List available Bedrock models"
echo ""
echo "Next steps:"
echo "  1. Create AWS profile:"
echo "     aws configure --profile moaaa_api_services"
echo ""
echo "  2. Verify profile:"
echo "     npm run aws:check-profile"
echo ""