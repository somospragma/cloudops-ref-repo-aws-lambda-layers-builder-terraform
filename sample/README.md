# Ejemplos: Lambda Layers Builder

Esta carpeta contiene ejemplos prácticos del módulo `lambda-layers-builder` para diferentes casos de uso y tecnologías.

## 📁 Estructura de Ejemplos

```
examples/
├── README.md           # Este archivo
├── basic/             # Ejemplo básico con comandos simples
├── python/            # Layers de Python con pip
├── nodejs/            # Layers de Node.js con npm
└── integration/       # Integración completa builder + deploy
```

## 🚀 Ejemplos Disponibles

### 1. [Basic](./basic/) - Ejemplo Básico
**Propósito**: Introducción al módulo con comandos simples
- ✅ Comandos directos básicos
- ✅ Creación de archivos simples
- ✅ Configuración mínima
- ⏱️ **Tiempo**: ~2 minutos

### 2. [Python](./python/) - Layers de Python
**Propósito**: Compilación de dependencias Python
- ✅ Script personalizado para requests
- ✅ Comandos directos para pandas
- ✅ Optimizaciones de tamaño
- ✅ Limpieza automática
- ⏱️ **Tiempo**: ~5 minutos

### 3. [Node.js](./nodejs/) - Layers de Node.js
**Propósito**: Compilación de dependencias JavaScript
- ✅ Script para AWS SDK v3
- ✅ Comandos para utilities (lodash, axios)
- ✅ Layer mínimo con uuid
- ✅ Optimizaciones npm
- ⏱️ **Tiempo**: ~4 minutos

### 4. [Integration](./integration/) - Integración Completa
**Propósito**: Flujo completo build → deploy → AWS
- ✅ Builder + Deploy modules
- ✅ Mapeo automático de outputs
- ✅ Despliegue a AWS Lambda
- ✅ Trazabilidad completa
- ⏱️ **Tiempo**: ~8 minutos

## 🎯 Guía de Selección

### Para Empezar
👉 **Comienza con [Basic](./basic/)** si es tu primera vez usando el módulo

### Por Tecnología
- 🐍 **Python**: Usa [Python](./python/) para layers con pip
- 🟨 **Node.js**: Usa [Node.js](./nodejs/) para layers con npm
- 🔧 **Otros**: Adapta [Basic](./basic/) para tu tecnología

### Por Caso de Uso
- 📚 **Aprendizaje**: [Basic](./basic/) → [Python](./python/) → [Node.js](./nodejs/)
- 🏗️ **Desarrollo**: [Python](./python/) o [Node.js](./nodejs/)
- 🚀 **Producción**: [Integration](./integration/)

## ⚡ Inicio Rápido

### 1. Clonar y Navegar
```bash
cd examples/basic
```

### 2. Inicializar
```bash
terraform init
```

### 3. Ejecutar
```bash
terraform apply
```

### 4. Verificar
```bash
terraform output
```

## 🛠️ Requisitos por Ejemplo

### Todos los Ejemplos
- ✅ Terraform >= 1.0
- ✅ Provider null >= 3.0
- ✅ Provider archive >= 2.0

### Python Examples
- ✅ Python 3.12+
- ✅ pip
- ✅ Permisos de escritura

### Node.js Examples
- ✅ Node.js 18+
- ✅ npm
- ✅ Permisos de escritura

### Integration Example
- ✅ Todo lo anterior
- ✅ AWS CLI configurado
- ✅ Provider AWS >= 4.31.0
- ✅ Credenciales AWS válidas

## 📋 Checklist Pre-Ejecución

### Verificar Herramientas
```bash
# Terraform
terraform version

# Python (para ejemplos Python)
python3 --version
pip --version

# Node.js (para ejemplos Node.js)
node --version
npm --version

# AWS (para ejemplo Integration)
aws --version
aws sts get-caller-identity
```

### Verificar Permisos
```bash
# Permisos de escritura en directorio actual
touch test-file && rm test-file

# Permisos de ejecución para scripts (ejemplos Python/Node.js)
ls -la */scripts/*.sh
```

## 🔧 Personalización

### Cambiar Configuración Base
Todos los ejemplos usan estas variables por defecto:
```hcl
client      = "pragma"
project     = "genai" 
environment = "dev"
```

Para cambiar:
```bash
# Opción 1: Variables en línea
terraform apply -var="client=myclient" -var="project=myproject"

# Opción 2: Archivo terraform.tfvars
echo 'client = "myclient"' > terraform.tfvars
echo 'project = "myproject"' >> terraform.tfvars
```

### Añadir Nuevos Layers
```hcl
layers_config = {
  # Layers existentes...
  
  my-custom-layer = {
    type        = "compile"
    description = "My custom layer"
    commands = [
      "mkdir -p build/custom",
      "echo 'custom content' > build/custom/file.txt"
    ]
    source_dir = "build/custom"
    filename   = "layers/custom.zip"
    runtime    = "python3.12"
  }
}
```

## 🐛 Troubleshooting Común

### Error: "command not found"
```bash
# Verificar PATH
echo $PATH

# Instalar herramientas faltantes (macOS)
brew install python node

# Instalar herramientas faltantes (Ubuntu)
sudo apt-get install python3 python3-pip nodejs npm
```

### Error: "permission denied"
```bash
# Dar permisos a scripts
chmod +x examples/*/scripts/*.sh

# Verificar permisos de directorio
ls -la examples/
```

### Error: "module not found"
```bash
# Verificar ruta del módulo en source
# Ajustar según tu estructura de directorios
source = "../../"  # Para ejemplos
source = "./modules/lambda-layers-builder"  # Para uso real
```

## 📚 Recursos Adicionales

- 📖 [README Principal](../README.md) - Documentación completa del módulo
- 📝 [CHANGELOG](../CHANGELOG.md) - Historial de cambios
- 🏗️ [Módulo de Despliegue](../../cloudops-ref-repo-aws-lambda-layers-terraform/) - Para desplegar layers a AWS

## 💡 Contribuir

¿Tienes un ejemplo útil? ¡Contribuye!

1. Crea directorio: `examples/mi-ejemplo/`
2. Añade `main.tf` y `README.md`
3. Documenta requisitos y uso
4. Actualiza este README

## 🧹 Limpieza

Para limpiar todos los ejemplos:
```bash
# Desde el directorio examples/
for dir in */; do
  if [ -f "$dir/main.tf" ]; then
    echo "Cleaning $dir"
    cd "$dir"
    terraform destroy -auto-approve 2>/dev/null || true
    rm -rf .terraform* terraform.tfstate* build/ layers/
    cd ..
  fi
done
```