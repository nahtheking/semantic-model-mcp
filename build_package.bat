@echo off
cls
echo 🚀 Semantic Model MCP Server - Package Build Script
echo ==================================================

echo 📋 Checking prerequisites...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python is not installed or not in PATH
    pause
    exit /b 1
)

where pip >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ pip is not installed or not in PATH
    pause
    exit /b 1
)

echo ✅ Python and pip are available

echo.
echo 📦 Installing build dependencies...
pip install --upgrade pip setuptools wheel build twine

echo.
echo 🧹 Cleaning previous builds...
if exist "dist" rmdir /s /q "dist"
if exist "build" rmdir /s /q "build"
for /d %%i in (*.egg-info) do rmdir /s /q "%%i"

echo.
echo 🔨 Building package...
python -m build

if %errorlevel% neq 0 (
    echo ❌ Build failed
    pause
    exit /b 1
)

echo ✅ Package built successfully

echo.
echo 🔍 Checking package...
python -m twine check dist/*

if %errorlevel% neq 0 (
    echo ❌ Package check failed
    pause
    exit /b 1
)

echo ✅ Package check passed

echo.
echo 📄 Generated files:
dir dist\

echo.
set /p test_install="🧪 Test install the package locally? (y/n): "

if /i "%test_install%"=="y" (
    echo 🧪 Testing local installation...
    
    REM Create temporary virtual environment
    python -m venv .test_env
    call .test_env\Scripts\activate.bat
    
    REM Install the package
    for %%f in (dist\*.whl) do pip install "%%f"
    
    REM Test import
    python -c "from semantic_model_mcp_server import __version__; print(f'Version: {__version__.__version__}')"
    
    if %errorlevel% equ 0 (
        echo ✅ Local installation test passed
    ) else (
        echo ❌ Local installation test failed
    )
    
    REM Cleanup
    call deactivate
    rmdir /s /q .test_env
)

echo.
echo 🎉 Package preparation complete!
echo.
echo 📋 Next steps:
echo 1. Review the generated files in dist\
echo 2. Test the package in a clean environment
echo 3. Commit all changes to git
echo 4. Create a git tag: git tag v0.3.0
echo 5. Push to trigger GitHub Actions: git push origin v0.3.0
echo 6. Monitor the GitHub Actions workflow
echo.
echo 🔗 Useful commands:
echo    View package info: python -m twine check dist\*
echo    Test upload (dry run): python -m twine upload --repository testpypi dist\* --dry-run
echo    Create git tag: git tag v0.3.0 ^&^& git push origin v0.3.0

pause