#!/bin/bash

# =============================================================================
# z_01_setup_venv.sh
# Creates Python 3.11 virtual environment for moaaa_api_services
# Location: ~/runtime_data/delete_me_later/python_venvs/moaaa_api_services
# =============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Step 1: Creating Virtual Environment"
echo "=========================================="

# Check if Python 3.11 is available
if ! command -v python3.11 &> /dev/null; then
    echo "ERROR: Python 3.11 is not installed"
    echo "Please install Python 3.11 first"
    exit 1
fi

echo "Python 3.11 found: $(python3.11 --version)"

# Define venv path in user home
VENV_BASE_DIR="$HOME/runtime_data/delete_me_later/python_venvs"
VENV_NAME="moaaa_api_services"
VENV_PATH="$VENV_BASE_DIR/$VENV_NAME"

echo "Venv location: $VENV_PATH"

# Create base directory if not exists
if [ ! -d "$VENV_BASE_DIR" ]; then
    echo "Creating directory: $VENV_BASE_DIR"
    mkdir -p "$VENV_BASE_DIR"
fi

# Check if venv already exists
if [ -d "$VENV_PATH" ]; then
    echo "Virtual environment already exists at: $VENV_PATH"
    read -p "Do you want to recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$VENV_PATH"
        echo "Removed existing virtual environment"
    else
        echo "Keeping existing virtual environment"
        exit 0
    fi
fi

echo "Creating virtual environment: $VENV_PATH"
python3.11 -m venv "$VENV_PATH"

echo ""
echo "=========================================="
echo "Virtual environment created successfully!"
echo "=========================================="
echo ""
echo "Location: $VENV_PATH"
echo ""
echo "To activate, run:"
echo "  source $VENV_PATH/bin/activate"
echo ""
echo "Next step:"
echo "  ./setup-scripts/z_02_setup_django_project.sh"
echo ""