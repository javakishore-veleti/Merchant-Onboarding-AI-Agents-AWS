#!/bin/bash

# =============================================================================
# z_05_setup_root_files.sh
# Creates root files: README.md, LICENSE, .gitignore
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 5: Creating Root Files"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# =============================================================================
# Create README.md
# =============================================================================
echo "Creating README.md..."
cat > "$PROJECT_ROOT/README.md" << 'EOF'
# Merchant-Onboarding-AI-Agents-AWS

AI-powered merchant onboarding platform using Amazon Bedrock, AgentCore, and Nova Act.

## 🎯 What This Project Does

A payment processor (APP - Acme Payment Platform) needs to onboard merchants quickly. This project demonstrates how to automate the onboarding process using AWS AI services.

## 🏪 The Scenario

**APP (Acme Payment Platform)** onboards merchants like **CoffeeShop** (a local coffee shop) to accept card payments. Merchants submit documents (business license, bank statement, etc.) and wait for approval.

**The Problem:**
- Manual document review takes 3-5 days
- Merchants call asking "What's my status?" repeatedly
- Operations team manually enters data into multiple portals

**The Solution:**
- AI agents that classify and extract document data automatically
- Conversational agent that answers merchant questions 24/7
- Browser automation that provisions accounts without manual work

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Django 5.x, Django REST Framework |
| **AI/ML** | Amazon Bedrock, AgentCore, Nova Act |
| **Database** | PostgreSQL |
| **Cloud** | AWS (S3, Lambda, EventBridge, DynamoDB) |
| **Frontend** | Angular (planned) |

## 📁 Project Structure

```
Merchant-Onboarding-AI-Agents-AWS/
├── moaaa_api_services/              # Django API project
│   ├── merchant_profile/            # Domain: Merchant entity
│   ├── application_profile/         # Domain: Merchant applications
│   ├── document_classification/     # AI/ML: Document classification
│   ├── document_extraction/         # AI/ML: Data extraction
│   ├── support_agent/               # AI/ML: Conversational agent
│   └── browser_automation/          # AI/ML: Portal automation
├── moaaa_portal_admin/              # Angular admin portal (planned)
├── moaaa_portal_customer/           # Angular customer portal (planned)
└── setup-scripts/                   # Setup automation scripts
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Node.js 18+ (for npm scripts)
- AWS Account with Bedrock access

### Setup

```bash
# Clone repository
git clone https://github.com/javakishore-veleti/Merchant-Onboarding-AI-Agents-AWS.git
cd Merchant-Onboarding-AI-Agents-AWS

# Run setup scripts in order
./setup-scripts/z_01_setup_venv.sh
./setup-scripts/z_02_setup_django_project.sh
./setup-scripts/z_02a_setup_package_json.sh
./setup-scripts/z_03_setup_domain_apps.sh
./setup-scripts/z_04_setup_aiml_apps.sh
./setup-scripts/z_05_setup_root_files.sh

# Or run all at once
npm run setup:all
```

### Run Development Server

```bash
npm run django:runserver
```

Visit: http://127.0.0.1:8000/

## 📜 Available Commands

| Command | Purpose |
|---------|---------|
| `npm run django:runserver` | Start Django server |
| `npm run django:migrate` | Run migrations |
| `npm run django:makemigrations` | Create migrations |
| `npm run django:shell` | Django shell |
| `npm run django:createsuperuser` | Create admin user |
| `npm run django:test` | Run tests |
| `npm run pip:install` | Install requirements |

## 🎭 Pseudo Names Used

| Name | Represents |
|------|------------|
| **APP** | Acme Payment Platform - The payment processor |
| **CoffeeShop** | A local coffee shop applying for payment processing |
| **TechMart** | An online electronics store |
| **QuickFix** | A mobile repair service company |

## 📚 Related Articles

- [DZone: Document Classification with Amazon Bedrock Data Automation](#) *(coming soon)*
- [DZone: Building a Merchant Support Agent with AgentCore](#) *(coming soon)*

## 👤 Author

**Kishore Veleti**
- GitHub: [@javakishore-veleti](https://github.com/javakishore-veleti)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
EOF

# =============================================================================
# Create LICENSE
# =============================================================================
echo "Creating LICENSE..."
cat > "$PROJECT_ROOT/LICENSE" << 'EOF'
MIT License

Copyright (c) 2026 Kishore Veleti

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# =============================================================================
# Create .gitignore
# =============================================================================
echo "Creating .gitignore..."
cat > "$PROJECT_ROOT/.gitignore" << 'EOF'
# =============================================================================
# Python
# =============================================================================
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# =============================================================================
# Virtual Environments
# =============================================================================
venv/
ENV/
env/
.venv/
moaaa_api_services_venv/

# =============================================================================
# Django
# =============================================================================
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
media/
staticfiles/

# =============================================================================
# IDE
# =============================================================================
.idea/
.vscode/
*.swp
*.swo
*~
.project
.pydevproject
.settings/

# =============================================================================
# AWS
# =============================================================================
.aws/
*.pem
.env
.env.local
.env.*.local

# =============================================================================
# Node
# =============================================================================
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# =============================================================================
# OS
# =============================================================================
.DS_Store
Thumbs.db
*.bak
*.tmp
*.temp

# =============================================================================
# Testing
# =============================================================================
.coverage
htmlcov/
.tox/
.pytest_cache/
coverage.xml
*.cover

# =============================================================================
# Documentation
# =============================================================================
docs/_build/
site/
EOF

echo ""
echo "=========================================="
echo "Root files created successfully!"
echo "=========================================="
echo ""
echo "Files created:"
echo "  - README.md"
echo "  - LICENSE"
echo "  - .gitignore"
echo ""
echo "=========================================="
echo "SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. npm run django:migrate"
echo "  2. npm run django:createsuperuser"
echo "  3. npm run django:runserver"
echo ""
echo "Visit: http://127.0.0.1:8000/"
echo ""