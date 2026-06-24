# Ejemplo Básico: Lambda Layers Builder

Este ejemplo demuestra el uso básico del módulo `lambda-layers-builder` para compilar un layer simple usando comandos directos.

## Descripción

El ejemplo crea un layer básico de utilidades que contiene un archivo JavaScript simple. Es ideal para entender el flujo básico del módulo.

## Estructura

```
basic/
├── main.tf          # Configuración principal
└── README.md        # Este archivo
```

## Configuración

### Layer Creado

- **Nombre**: `pragma-demo-dev-layer-utils-layer`
- **Tipo**: Compilación con comandos directos
- **Runtime**: Node.js 22.x
- **Contenido**: Archivo JavaScript básico

### Comandos Ejecutados

1. `mkdir -p build/utils` - Crea directorio de build
2. `echo 'console.log("Hello from layer!");' > build/utils/index.js` - Crea archivo JS

## Uso

### 1. Inicializar Terraform

```bash
terraform init
```

### 2. Planificar Despliegue

```bash
terraform plan
```

### 3. Aplicar Configuración

```bash
terraform apply
```

### 4. Verificar Resultados

```bash
# Ver información de layers compilados
terraform output compiled_layers

# Ver resumen de build
terraform output build_summary
```

## Resultados Esperados

Después de ejecutar `terraform apply`, se generará:

- **Directorio**: `build/utils/` con archivo `index.js`
- **ZIP**: `layers/utils-layer.zip` con el contenido compilado
- **Hash**: SHA256 del archivo ZIP para verificación de integridad

## Outputs

### compiled_layers
```json
{
  "utils-layer": {
    "hash": "base64-encoded-sha256-hash",
    "path": "layers/utils-layer.zip",
    "size": 1234
  }
}
```

### build_summary
```json
{
  "layer_names": ["utils-layer"],
  "total_layers_compiled": 1,
  "zip_files": {
    "utils-layer": {
      "filename": "layers/utils-layer.zip",
      "size_mb": 0.01
    }
  }
}
```

## Limpieza

```bash
terraform destroy
```

## Siguientes Pasos

- Revisar [ejemplo de Python](../python/) para layers más complejos
- Revisar [ejemplo de Node.js](../nodejs/) para dependencias npm
- Revisar [ejemplo de integración](../integration/) para uso con módulo de despliegue