###########################################
# Ejemplo Python: Lambda Layers Builder  #
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
  project     = "genai"
  environment = "dev"
  
  layers_config = {
    # Layer Python con script personalizado
    requests-layer = {
      type        = "compile"
      description = "Python requests library layer"
      script_path = "scripts/build-requests.sh"
      source_dir  = "build/python"
      filename    = "layers/requests-layer.zip"
      runtime     = "python3.12"
      additional_tags = {
        Purpose = "http-client"
        Library = "requests"
      }
    }
    
    # Layer Python con comandos directos
    pandas-layer = {
      type        = "compile"
      description = "Python pandas library layer"
      commands = [
        "mkdir -p build/pandas/python/lib/python3.12/site-packages",
        "pip install pandas numpy -t build/pandas/python/lib/python3.12/site-packages",
        "find build/pandas -name '*.pyc' -delete",
        "find build/pandas -name '__pycache__' -type d -exec rm -rf {} +"
      ]
      source_dir = "build/pandas"
      filename   = "layers/pandas-layer.zip"
      runtime    = "python3.12"
      additional_tags = {
        Purpose = "data-analysis"
        Library = "pandas"
      }
    }
  }
}

###########################################
# Outputs para Verificación              #
###########################################

output "compiled_layers" {
  description = "Information about compiled Python layers"
  value       = module.lambda_layers_builder.compiled_zips
}

output "layer_names" {
  description = "Generated layer names"
  value       = module.lambda_layers_builder.layer_names
}

output "build_info" {
  description = "Build information for debugging"
  value       = module.lambda_layers_builder.build_info
}