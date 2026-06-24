###########################################
# Ejemplo Básico: Lambda Layers Builder  #
###########################################

terraform {
  required_version = ">= 1.0"
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

###########################################
# Configuración del Módulo Builder       #
###########################################

module "lambda_layers_builder" {
  source = "../../"
  
  client      = "pragma"
  project     = "demo"
  environment = "dev"
  
  layers_config = {
    # Layer simple con comandos directos
    utils-layer = {
      type        = "compile"
      description = "Basic utilities layer"
      commands = [
        "mkdir -p build/utils",
        "echo 'console.log(\"Hello from layer!\");' > build/utils/index.js"
      ]
      source_dir = "build/utils"
      filename   = "layers/utils-layer.zip"
      runtime    = "nodejs22.x"
    }
  }
}

###########################################
# Outputs para Verificación              #
###########################################

output "compiled_layers" {
  description = "Information about compiled layers"
  value       = module.lambda_layers_builder.compiled_zips
}

output "build_summary" {
  description = "Build summary"
  value       = module.lambda_layers_builder.summary
}