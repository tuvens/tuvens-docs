#!/bin/bash

# Multi-LLM Integration Setup Script
# Installs and configures LiteLLM router with all dependencies

set -e

echo "🚀 Setting up Multi-LLM Integration System"
echo "=========================================="

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | grep -Po '(?<=Python )\d+\.\d+')
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Python $REQUIRED_VERSION or higher is required (found $PYTHON_VERSION)"
    exit 1
fi

echo "✅ Python version check passed ($PYTHON_VERSION)"

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📚 Installing dependencies..."
pip install --upgrade pip
pip install 'litellm[proxy,redis]' langfuse openai anthropic google-generativeai

# Check for .env file
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and add your API keys"
fi

# Create necessary directories
mkdir -p logs
mkdir -p cache

# Check Redis
if command -v redis-cli &> /dev/null; then
    echo "✅ Redis is installed"
    if redis-cli ping &> /dev/null; then
        echo "✅ Redis is running"
    else
        echo "⚠️  Redis is installed but not running. Start with: redis-server"
    fi
else
    echo "⚠️  Redis not found. Install for caching support:"
    echo "    macOS: brew install redis"
    echo "    Ubuntu: sudo apt-get install redis-server"
fi

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    if docker ps &> /dev/null; then
        echo "✅ Docker is running"
    else
        echo "⚠️  Docker is installed but not running"
    fi
else
    echo "⚠️  Docker not found. Install for production deployment"
fi

# Test configuration
echo ""
echo "🧪 Testing configuration..."
python3 scripts/test_routing.py

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your API keys"
echo "2. Start the router: litellm --config config/litellm.yaml --port 4000"
echo "3. Or use Docker: docker-compose up -d"
echo "4. Test integration: python scripts/test_routing.py"
echo ""
echo "📚 Documentation: agentic-development/llm-integration/README.md"
