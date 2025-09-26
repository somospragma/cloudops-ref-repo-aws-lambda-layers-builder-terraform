#!/bin/bash
set -e

echo "🚀 Building Node.js AWS SDK v3 layer..."

# Limpiar build anterior
rm -rf build/nodejs
mkdir -p build/nodejs/nodejs

echo "📦 Installing AWS SDK v3 dependencies..."

# Crear package.json temporal
cat > build/nodejs/package.json << EOF
{
  "name": "aws-sdk-layer",
  "version": "1.0.0",
  "dependencies": {
    "@aws-sdk/client-s3": "^3.0.0",
    "@aws-sdk/client-dynamodb": "^3.0.0",
    "@aws-sdk/client-lambda": "^3.0.0",
    "@aws-sdk/client-secrets-manager": "^3.0.0"
  }
}
EOF

# Instalar dependencias
cd build/nodejs
npm install --production --no-optional

echo "🧹 Cleaning unnecessary files..."

# Mover node_modules al directorio correcto
mv node_modules nodejs/

# Limpiar archivos innecesarios
rm package.json package-lock.json
find nodejs -name "*.md" -delete 2>/dev/null || true
find nodejs -name "*.txt" -delete 2>/dev/null || true
find nodejs -name "*.ts" -delete 2>/dev/null || true
find nodejs -name "test*" -type d -exec rm -rf {} + 2>/dev/null || true
find nodejs -name "example*" -type d -exec rm -rf {} + 2>/dev/null || true

cd ../..

echo "📊 Layer statistics:"
echo "   Size: $(du -sh build/nodejs | cut -f1)"
echo "   Modules: $(find build/nodejs/nodejs/node_modules -maxdepth 1 -type d | wc -l)"

echo "✅ Node.js AWS SDK layer build completed!"