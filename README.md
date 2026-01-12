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
