# Ejemplo Python: Lambda Layers Builder

Este ejemplo demuestra la compilación de layers de Python usando tanto scripts personalizados como comandos directos.

## Descripción

El ejemplo crea dos layers de Python:
1. **requests-layer**: Usando script personalizado (`build-requests.sh`)
2. **pandas-layer**: Usando comandos directos en Terraform

## Estructura

```
python/
├── main.tf                    # Configuración principal
├── README.md                  # Este archivo
└── scripts/
    └── build-requests.sh      # Script de build para requests
```

## Layers Creados

### 1. requests-layer
- **Método**: Script personalizado
- **Dependencias**: requests, urllib3, certifi, charset-normalizer, idna
- **Runtime**: Python 3.12
- **Optimizaciones**: Limpieza de archivos .pyc, __pycache__, tests

### 2. pandas-layer
- **Método**: Comandos directos
- **Dependencias**: pandas, numpy
- **Runtime**: Python 3.12
- **Optimizaciones**: Limpieza automática de archivos temporales

## Uso

### 1. Preparar Entorno

```bash
# Asegurar que pip esté disponible
python3 -m pip --version

# Dar permisos de ejecución al script
chmod +x scripts/build-requests.sh
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Planificar y Aplicar

```bash
terraform plan
terraform apply
```

### 4. Verificar Resultados

```bash
# Ver layers compilados
terraform output compiled_layers

# Ver nombres generados
terraform output layer_names

# Ver información de build
terraform output build_info
```

## Resultados Esperados

### Archivos Generados
- `build/python/` - Directorio con requests layer
- `build/pandas/` - Directorio con pandas layer
- `layers/requests-layer.zip` - ZIP del requests layer
- `layers/pandas-layer.zip` - ZIP del pandas layer

### Outputs

#### compiled_layers
```json
{
  "requests-layer": {
    "hash": "sha256-hash-requests",
    "path": "layers/requests-layer.zip",
    "size": 2048576
  },
  "pandas-layer": {
    "hash": "sha256-hash-pandas", 
    "path": "layers/pandas-layer.zip",
    "size": 52428800
  }
}
```

#### layer_names
```json
{
  "requests-layer": "pragma-genai-dev-layer-requests-layer",
  "pandas-layer": "pragma-genai-dev-layer-pandas-layer"
}
```

## Personalización del Script

### Modificar build-requests.sh

```bash
#!/bin/bash
set -e

# Agregar más dependencias
pip install requests beautifulsoup4 lxml -t build/python/python/lib/python3.12/site-packages

# Optimizaciones adicionales
find build/python -name "*.so" -exec strip {} \; 2>/dev/null || true
```

### Comandos Directos Avanzados

```hcl
commands = [
  "mkdir -p build/advanced/python/lib/python3.12/site-packages",
  "pip install --no-deps requests -t build/advanced/python/lib/python3.12/site-packages",
  "pip install --no-deps urllib3==1.26.18 -t build/advanced/python/lib/python3.12/site-packages",
  "find build/advanced -name '*.pyc' -delete"
]
```

## Troubleshooting

### Error: pip no encontrado
```bash
# Instalar pip si no está disponible
python3 -m ensurepip --upgrade
```

### Error: Permisos de script
```bash
# Dar permisos de ejecución
chmod +x scripts/build-requests.sh
```

### Layer muy grande
```bash
# Verificar tamaño antes de comprimir
du -sh build/python
du -sh build/pandas

# Optimizar eliminando archivos innecesarios
find build/ -name "*.dist-info" -type d -exec rm -rf {} +
```

## Limpieza

```bash
terraform destroy
rm -rf build/ layers/
```

## Siguientes Pasos

- Revisar [ejemplo de Node.js](../nodejs/) para layers de JavaScript
- Revisar [ejemplo de integración](../integration/) para despliegue completo