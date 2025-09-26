#!/bin/bash
set -e

echo "🐍 Building Python requests layer..."

# Limpiar build anterior
rm -rf build/python
mkdir -p build/python/python/lib/python3.12/site-packages

echo "📦 Installing Python dependencies..."

# Instalar requests y dependencias
pip install requests urllib3 certifi charset-normalizer idna -t build/python/python/lib/python3.12/site-packages

echo "🧹 Cleaning unnecessary files..."

# Limpiar archivos innecesarios
find build/python -name "*.pyc" -delete
find build/python -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find build/python -name "*.dist-info" -type d -exec rm -rf {} + 2>/dev/null || true
find build/python -name "tests" -type d -exec rm -rf {} + 2>/dev/null || true

echo "📊 Layer statistics:"
echo "   Size: $(du -sh build/python | cut -f1)"
echo "   Files: $(find build/python -type f | wc -l)"

echo "✅ Python requests layer build completed!"