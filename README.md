# Módulo Terraform: lambda-layers-builder

## Descripción

Este módulo gestiona la construcción y compilación de AWS Lambda Layers. Se encarga de ejecutar scripts de build, instalar dependencias y generar archivos ZIP optimizados que posteriormente pueden ser desplegados usando el módulo `lambda-layers`.

Para más detalles sobre los cambios y versiones, consulte el [CHANGELOG.md](./CHANGELOG.md).

## ✅ Características

- ✅ Compilación automática de layers mediante scripts
- ✅ Soporte para comandos directos (ideal para Backstage)
- ✅ Generación automática de archivos ZIP
- ✅ Cálculo automático de hashes para integridad
- ✅ Sistema de etiquetado consistente
- ✅ Validaciones de entrada robustas
- ✅ Separación clara de responsabilidades (build vs deploy)
- ✅ Compatibilidad con múltiples runtimes y arquitecturas
- ✅ Optimización para pipelines CI/CD

## Estructura del Módulo

```
lambda-layers-builder/
├── README.md           # Este archivo
├── CHANGELOG.md        # Historial de cambios
├── main.tf            # Recursos principales
├── variables.tf       # Variables de entrada
├── outputs.tf         # Valores de salida
├── providers.tf       # Configuración de proveedores
└── examples/          # Ejemplos de uso
    ├── basic/         # Ejemplo básico
    ├── nodejs/        # Ejemplo Node.js
    └── python/        # Ejemplo Python
```

## Implementación y Configuración

### Requisitos Técnicos

- **Terraform**: >= 1.0
- **Provider Null**: >= 3.0
- **Provider Archive**: >= 2.0

### Provider Configuration

```hcl
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.0"
    }
  }
}
```

### Convenciones de Nomenclatura

Los layers generados siguen la convención:
```
{client}-{project}-{environment}-layer-{name}
```

Ejemplo: `pragma-genai-dev-layer-requests`

### Estrategia de Etiquetado

El módulo genera información de etiquetado siguiendo la estrategia corporativa:
- **Name**: Nombre del layer generado
- **Environment**: Entorno de despliegue
- **Client**: Cliente propietario
- **Project**: Proyecto asociado

### Recursos Gestionados

- `null_resource.layer_compilation`: Ejecuta scripts/comandos de compilación
- `data.archive_file.compiled_layers`: Genera archivos ZIP de los layers compilados

### Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_layers_config"></a> [layers_config](#input_layers_config) | Mapa de configuración de layers a compilar | `map(object)` | `{}` | yes |
| <a name="input_client"></a> [client](#input_client) | Nombre del cliente para etiquetado | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input_project) | Nombre del proyecto para etiquetado | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | yes |

### Estructura de Configuración

```hcl
layers_config = {
  layer-name = {
    type        = "compile"  # Solo acepta "compile"
    description = "Descripción del layer"
    
    # Opción 1: Script de build personalizado
    script_path = "scripts/build-layer.sh"
    
    # Opción 2: Comandos directos (para Backstage)
    commands = [
      "mkdir -p python/lib/python3.12/site-packages",
      "pip install requests -t python/lib/python3.12/site-packages"
    ]
    
    # Configuración de salida (requerida)
    source_dir = "build/python"      # Directorio creado por script/comandos
    filename   = "layers/requests.zip" # Archivo ZIP de salida
    
    # Configuración AWS (para referencia)
    runtime      = "python3.12"
    architecture = "x86_64"
    
    # Etiquetas adicionales
    additional_tags = {
      Purpose = "http-requests"
    }
  }
}
```

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="output_compiled_zips"></a> [compiled_zips](#output_compiled_zips) | Información de ZIPs compilados (path, hash, size) |
| <a name="output_layer_names"></a> [layer_names](#output_layer_names) | Nombres generados para los layers |
| <a name="output_summary"></a> [summary](#output_summary) | Resumen de layers compilados |
| <a name="output_build_info"></a> [build_info](#output_build_info) | Información de build para debugging |

### Ejemplos de Uso

#### Ejemplo 1: Layer Python con Script

```hcl
module "lambda_layers_builder" {
  source = "./modules/lambda-layers-builder"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  layers_config = {
    requests-layer = {
      type        = "compile"
      description = "Python requests library layer"
      script_path = "scripts/build-python-requests.sh"
      source_dir  = "build/python"
      filename    = "layers/requests-layer.zip"
      runtime     = "python3.12"
    }
  }
}
```

#### Ejemplo 2: Layer Node.js con Comandos Directos

```hcl
module "lambda_layers_builder" {
  source = "./modules/lambda-layers-builder"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  layers_config = {
    aws-sdk-layer = {
      type        = "compile"
      description = "AWS SDK v3 layer for Node.js"
      commands = [
        "mkdir -p nodejs/node_modules",
        "cd nodejs && npm install @aws-sdk/client-s3 @aws-sdk/client-dynamodb",
        "cd .."
      ]
      source_dir = "nodejs"
      filename   = "layers/aws-sdk-layer.zip"
      runtime    = "nodejs22.x"
    }
  }
}
```

#### Ejemplo 3: Múltiples Layers

```hcl
module "lambda_layers_builder" {
  source = "./modules/lambda-layers-builder"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  layers_config = {
    python-utils = {
      type        = "compile"
      description = "Python utilities layer"
      script_path = "scripts/build-python-utils.sh"
      source_dir  = "build/python-utils"
      filename    = "layers/python-utils.zip"
      runtime     = "python3.12"
    }
    
    nodejs-utils = {
      type        = "compile"
      description = "Node.js utilities layer"
      commands = [
        "mkdir -p nodejs/node_modules",
        "cd nodejs && npm install lodash axios moment",
        "cd .."
      ]
      source_dir = "nodejs"
      filename   = "layers/nodejs-utils.zip"
      runtime    = "nodejs22.x"
    }
  }
}
```

## Integración con Módulo de Despliegue

### Uso Conjunto de Ambos Módulos

```hcl
# 1. Compilar layers
module "lambda_layers_builder" {
  source = "./modules/lambda-layers-builder"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  layers_config = {
    requests-layer = {
      type        = "compile"
      script_path = "scripts/build-requests.sh"
      source_dir  = "build/python"
      filename    = "layers/requests-layer.zip"
      runtime     = "python3.12"
    }
  }
}

# 2. Desplegar layers compilados
module "lambda_layers" {
  source = "./modules/lambda-layers"
  
  providers = {
    aws.project = aws
  }
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  layers_config = {
    for k, v in module.lambda_layers_builder.compiled_zips : k => {
      type     = "zip"
      zip_path = v.path
      zip_hash = v.hash
      description = "Compiled ${k} layer"
      runtime     = "python3.12"
    }
  }
  
  depends_on = [module.lambda_layers_builder]
}
```

## Escenarios de Uso Comunes

### 1. Desarrollo Local
- Scripts de build personalizados para cada layer
- Compilación incremental durante desarrollo
- Validación local antes del despliegue

### 2. Pipeline CI/CD con Backstage
- Comandos directos sin archivos de script
- Integración nativa con templates de Backstage
- Build automatizado en pipelines

### 3. Entornos Mixtos
- Combinación de scripts y comandos según necesidad
- Reutilización de layers entre proyectos
- Optimización de tiempos de build

## Scripts de Build Recomendados

### Script Python (build-python-requests.sh)

```bash
#!/bin/bash
set -e

echo "Building Python requests layer..."

# Crear estructura de directorios
mkdir -p build/python/lib/python3.12/site-packages

# Instalar dependencias
pip install requests urllib3 certifi -t build/python/lib/python3.12/site-packages

# Limpiar archivos innecesarios
find build/python -name "*.pyc" -delete
find build/python -name "__pycache__" -type d -exec rm -rf {} +

echo "Python layer build completed!"
```

### Script Node.js (build-nodejs-aws-sdk.sh)

```bash
#!/bin/bash
set -e

echo "Building Node.js AWS SDK layer..."

# Crear estructura de directorios
mkdir -p build/nodejs

# Crear package.json temporal
cat > build/nodejs/package.json << EOF
{
  "name": "aws-sdk-layer",
  "version": "1.0.0",
  "dependencies": {
    "@aws-sdk/client-s3": "^3.0.0",
    "@aws-sdk/client-dynamodb": "^3.0.0"
  }
}
EOF

# Instalar dependencias
cd build/nodejs
npm install --production
rm package.json package-lock.json
cd ../..

echo "Node.js layer build completed!"
```

## Consideraciones Operativas

### Performance
- Build paralelo de múltiples layers
- Cache de dependencias cuando sea posible
- Optimización de tamaños de ZIP

### Escalabilidad
- Soporte para builds complejos con múltiples pasos
- Integración con sistemas de CI/CD
- Gestión de dependencias por runtime

### Mantenimiento
- Separación clara entre build y deploy
- Trazabilidad completa de artefactos
- Validación de integridad con hashes

## Seguridad y Cumplimiento

### Controles de Seguridad
- Validación de comandos de entrada
- Verificación de integridad con hashes SHA256
- Aislamiento de procesos de build

### Cumplimiento
- Nomenclatura estándar corporativa
- Trazabilidad de artefactos generados
- Auditoría de comandos ejecutados

## Observaciones

- **Separación**: Este módulo solo construye, no despliega a AWS
- **Dependencias**: Asegurar que las herramientas de build estén disponibles (pip, npm, etc.)
- **Tamaño**: Monitorear tamaños de layers (límite 250MB sin comprimir)
- **Cache**: Considerar estrategias de cache para builds repetitivos
- **Limpieza**: Los scripts deben limpiar archivos temporales innecesarios

## Troubleshooting

### Errores Comunes

1. **Script no encontrado**: Verificar que `script_path` sea correcto
2. **Comandos fallan**: Validar que las herramientas estén instaladas
3. **Directorio vacío**: Asegurar que `source_dir` contenga archivos
4. **Permisos**: Verificar permisos de ejecución en scripts

### Debug

Usar el output `build_info` para verificar configuración:

```hcl
output "debug_build" {
  value = module.lambda_layers_builder.build_info
}
```