#!/bin/bash
# Package build and test script for Semantic Model MCP Server

echo "🚀 Semantic Model MCP Server - Package Build Script"
echo "=================================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command_exists python; then
    echo "❌ Python is not installed or not in PATH"
    exit 1
fi

if ! command_exists pip; then
    echo "❌ pip is not installed or not in PATH" 
    exit 1
fi

echo "✅ Python and pip are available"

# Install build dependencies
echo ""
echo "📦 Installing build dependencies..."
pip install --upgrade pip setuptools wheel build twine

# Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
if [ -d "dist" ]; then
    rm -rf dist/
fi
if [ -d "build" ]; then
    rm -rf build/
fi
if [ -d "*.egg-info" ]; then
    rm -rf *.egg-info/
fi

# Build the package
echo ""
echo "🔨 Building package..."
python -m build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Package built successfully"

# Check the package
echo ""
echo "🔍 Checking package..."
python -m twine check dist/*

if [ $? -ne 0 ]; then
    echo "❌ Package check failed"
    exit 1
fi

echo "✅ Package check passed"

# List generated files
echo ""
echo "📄 Generated files:"
ls -la dist/

# Test installation (optional)
echo ""
read -p "🧪 Test install the package locally? (y/n): " test_install

if [ "$test_install" = "y" ] || [ "$test_install" = "Y" ]; then
    echo "🧪 Testing local installation..."
    
    # Create temporary virtual environment
    python -m venv .test_env
    source .test_env/bin/activate
    
    # Install the package
    pip install dist/*.whl
    
    # Test import
    python -c "from semantic_model_mcp_server import __version__; print(f'Version: {__version__.__version__}')"
    
    if [ $? -eq 0 ]; then
        echo "✅ Local installation test passed"
    else
        echo "❌ Local installation test failed"
    fi
    
    # Cleanup
    deactivate
    rm -rf .test_env
fi

echo ""
echo "🎉 Package preparation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review the generated files in dist/"
echo "2. Test the package in a clean environment" 
echo "3. Commit all changes to git"
echo "4. Create a git tag: git tag v0.3.0"
echo "5. Push to trigger GitHub Actions: git push origin v0.3.0"
echo "6. Monitor the GitHub Actions workflow"
echo ""
echo "🔗 Useful commands:"
echo "   View package info: python -m twine check dist/*"
echo "   Test upload (dry run): python -m twine upload --repository testpypi dist/* --dry-run"
echo "   Create git tag: git tag v0.3.0 && git push origin v0.3.0"