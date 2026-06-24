###########################################
# Ejemplo Node.js: Lambda Layers Builder #
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
    # Layer AWS SDK con script personalizado
    aws-sdk-layer = {
      type        = "compile"
      description = "AWS SDK v3 layer for Node.js"
      script_path = "scripts/build-aws-sdk.sh"
      source_dir  = "build/nodejs"
      filename    = "layers/aws-sdk-layer.zip"
      runtime     = "nodejs22.x"
      additional_tags = {
        Purpose = "aws-integration"
        SDK     = "aws-sdk-v3"
      }
    }
    
    # Layer utilities con comandos directos
    utils-layer = {
      type        = "compile"
      description = "Node.js utilities layer"
      commands = [
        "mkdir -p build/utils/nodejs/node_modules",
        "cd build/utils/nodejs",
        "npm init -y",
        "npm install lodash axios moment uuid",
        "rm package.json package-lock.json",
        "cd ../../.."
      ]
      source_dir = "build/utils/nodejs"
      filename   = "layers/utils-layer.zip"
      runtime    = "nodejs22.x"
      additional_tags = {
        Purpose = "utilities"
        Type    = "common-libs"
      }
    }
    
    # Layer específico con dependencias mínimas
    minimal-layer = {
      type        = "compile"
      description = "Minimal Node.js layer"
      commands = [
        "mkdir -p build/minimal/nodejs/node_modules",
        "echo '{\"name\":\"minimal\",\"dependencies\":{\"uuid\":\"^9.0.0\"}}' > build/minimal/package.json",
        "cd build/minimal && npm install --production",
        "rm package.json package-lock.json",
        "cd ../.."
      ]
      source_dir = "build/minimal/nodejs"
      filename   = "layers/minimal-layer.zip"
      runtime    = "nodejs22.x"
    }
  }
}

###########################################
# Outputs para Verificación              #
###########################################

output "compiled_layers" {
  description = "Information about compiled Node.js layers"
  value       = module.lambda_layers_builder.compiled_zips
}

output "layer_names" {
  description = "Generated layer names"
  value       = module.lambda_layers_builder.layer_names
}

output "build_summary" {
  description = "Build summary with sizes"
  value       = module.lambda_layers_builder.summary
}