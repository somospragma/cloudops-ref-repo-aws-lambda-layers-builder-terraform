# Ejemplo Integración: Builder + Deploy

Este ejemplo demuestra la integración completa entre el módulo `lambda-layers-builder` y el módulo `lambda-layers` para un flujo completo de build y despliegue.

## Descripción

El ejemplo realiza el flujo completo:
1. **Build**: Compila layers usando el módulo builder
2. **Deploy**: Despliega los layers compilados a AWS usando el módulo de despliegue
3. **Integration**: Conecta automáticamente los outputs del builder con los inputs del deployer

## Arquitectura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Source Code     │───▶│ Builder Module   │───▶│ Deploy Module   │
│ + Dependencies  │    │ (Compile + ZIP)  │    │ (AWS Layers)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Estructura

```
integration/
├── main.tf          # Configuración completa
└── README.md        # Este archivo
```

## Layers Procesados

### 1. requests-layer (Python)
- **Build**: Comandos directos para instalar requests
- **Deploy**: Layer de Python 3.12 en AWS
- **Uso**: Funciones Lambda que requieren HTTP requests

### 2. nodejs-utils (Node.js)
- **Build**: Comandos npm para instalar lodash y axios
- **Deploy**: Layer de Node.js 22.x en AWS
- **Uso**: Funciones Lambda que requieren utilidades JS

## Configuración

### Variables Disponibles

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "client" {
  default = "pragma"
}

variable "project" {
  default = "genai"
}

variable "environment" {
  default = "dev"
}
```

### Personalización

```bash
# Cambiar región
terraform apply -var="aws_region=us-west-2"

# Cambiar entorno
terraform apply -var="environment=qa"

# Cambiar proyecto
terraform apply -var="project=myproject"
```

## Uso

### 1. Preparar Entorno

```bash
# Verificar herramientas necesarias
python3 --version
pip --version
node --version
npm --version

# Configurar AWS CLI
aws configure
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Planificar Despliegue

```bash
terraform plan
```

### 4. Aplicar Configuración Completa

```bash
terraform apply
```

### 5. Verificar Resultados

```bash
# Ver resumen de build
terraform output build_summary

# Ver ARNs de layers desplegados
terraform output deployed_layers

# Ver versiones de layers
terraform output layer_versions

# Ver información completa de integración
terraform output integration_info
```

## Flujo de Ejecución

### Fase 1: Compilación (Builder Module)
1. Ejecuta comandos de build para cada layer
2. Crea directorios con dependencias instaladas
3. Genera archivos ZIP con hashes SHA256
4. Proporciona outputs con rutas y metadatos

### Fase 2: Despliegue (Deploy Module)
1. Toma los ZIPs generados por el builder
2. Crea recursos `aws_lambda_layer_version`
3. Aplica tags corporativos automáticamente
4. Retorna ARNs y versiones de layers

### Fase 3: Integración Automática
1. Los outputs del builder se mapean automáticamente a inputs del deployer
2. Se preservan metadatos y configuraciones
3. Se añaden tags adicionales de trazabilidad

## Outputs Esperados

### build_summary
```json
{
  "layer_names": ["requests-layer", "nodejs-utils"],
  "total_layers_compiled": 2,
  "zip_files": {
    "requests-layer": {
      "filename": "layers/requests-layer.zip",
      "size_mb": 2.1
    },
    "nodejs-utils": {
      "filename": "layers/nodejs-utils.zip", 
      "size_mb": 1.8
    }
  }
}
```

### deployed_layers
```json
{
  "requests-layer": "arn:aws:lambda:us-east-1:123456789012:layer:pragma-genai-dev-layer-requests-layer:1",
  "nodejs-utils": "arn:aws:lambda:us-east-1:123456789012:layer:pragma-genai-dev-layer-nodejs-utils:1"
}
```

### integration_info
```json
{
  "compiled_zips": {
    "requests-layer": {
      "hash": "sha256-abc123...",
      "path": "layers/requests-layer.zip",
      "size": 2097152
    }
  },
  "layer_arns": {
    "requests-layer": "arn:aws:lambda:us-east-1:123456789012:layer:pragma-genai-dev-layer-requests-layer:1"
  },
  "layer_names": {
    "requests-layer": "pragma-genai-dev-layer-requests-layer"
  }
}
```

## Uso en Funciones Lambda

### Python Function

```python
import requests  # Disponible desde el layer

def lambda_handler(event, context):
    response = requests.get('https://api.example.com/data')
    return {
        'statusCode': 200,
        'body': response.json()
    }
```

### Terraform para Lambda Function

```hcl
resource "aws_lambda_function" "example" {
  filename         = "function.zip"
  function_name    = "example-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.12"
  
  layers = [
    module.lambda_layers_deploy.layer_arns["requests-layer"]
  ]
}
```

## Troubleshooting

### Error: Módulo de despliegue no encontrado
```hcl
# Ajustar la ruta en main.tf
source = "path/to/lambda-layers-module"
```

### Error: Credenciales AWS
```bash
# Configurar AWS CLI
aws configure

# O usar variables de entorno
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### Error: Dependencias no instaladas
```bash
# Verificar herramientas
which python3 pip node npm

# Instalar si es necesario (macOS)
brew install python node
```

## Limpieza

```bash
# Destruir recursos AWS y archivos locales
terraform destroy

# Limpiar archivos de build
rm -rf build/ layers/
```

## Ventajas de la Integración

1. **Automatización Completa**: Un solo `terraform apply` para todo el flujo
2. **Consistencia**: Misma nomenclatura y tags en build y deploy
3. **Trazabilidad**: Conexión directa entre artefactos y recursos AWS
4. **Eficiencia**: Reutilización automática de outputs entre módulos
5. **Mantenibilidad**: Separación clara de responsabilidades

## Siguientes Pasos

- Integrar con pipelines CI/CD
- Añadir validaciones de calidad de código
- Implementar estrategias de versionado
- Configurar monitoreo de layers desplegados