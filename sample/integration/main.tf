###########################################
# Ejemplo Integración: Builder + Deploy  #
###########################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
    }
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

# Configurar provider AWS
provider "aws" {
  region = var.aws_region
}

###########################################
# Variables de Configuración             #
###########################################

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "client" {
  description = "Client name"
  type        = string
  default     = "pragma"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "genai"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

###########################################
# Paso 1: Compilar Layers                #
###########################################

module "lambda_layers_builder" {
  source = "../../"
  
  client      = var.client
  project     = var.project
  environment = var.environment
  
  layers_config = {
    # Layer Python requests
    requests-layer = {
      type        = "compile"
      description = "Python requests library layer"
      commands = [
        "mkdir -p build/requests/python/lib/python3.12/site-packages",
        "pip install requests -t build/requests/python/lib/python3.12/site-packages",
        "find build/requests -name '*.pyc' -delete",
        "find build/requests -name '__pycache__' -type d -exec rm -rf {} +"
      ]
      source_dir = "build/requests"
      filename   = "layers/requests-layer.zip"
      runtime    = "python3.12"
    }
    
    # Layer Node.js utilities
    nodejs-utils = {
      type        = "compile"
      description = "Node.js utilities layer"
      commands = [
        "mkdir -p build/nodejs-utils/nodejs/node_modules",
        "cd build/nodejs-utils/nodejs",
        "npm init -y",
        "npm install lodash axios",
        "rm package.json package-lock.json",
        "cd ../../.."
      ]
      source_dir = "build/nodejs-utils/nodejs"
      filename   = "layers/nodejs-utils.zip"
      runtime    = "nodejs22.x"
    }
  }
}

###########################################
# Paso 2: Desplegar Layers a AWS         #
###########################################

module "lambda_layers_deploy" {
  # Nota: Ajustar la ruta según la ubicación del módulo de despliegue
  source = "../../../cloudops-ref-repo-aws-lambda-layers-terraform"
  
  providers = {
    aws.project = aws
  }
  
  client      = var.client
  project     = var.project
  environment = var.environment
  
  # Convertir outputs del builder a configuración del deployer
  layers_config = {
    for k, v in module.lambda_layers_builder.compiled_zips : k => {
      type        = "zip"
      zip_path    = v.path
      zip_hash    = v.hash
      description = "Compiled ${k} layer"
      runtime     = k == "requests-layer" ? "python3.12" : "nodejs22.x"
      additional_tags = {
        BuildMethod = "terraform-builder"
        BuildTime   = timestamp()
      }
    }
  }
  
  depends_on = [module.lambda_layers_builder]
}

###########################################
# Outputs Completos                      #
###########################################

output "build_summary" {
  description = "Summary of compiled layers"
  value       = module.lambda_layers_builder.summary
}

output "deployed_layers" {
  description = "ARNs of deployed Lambda layers"
  value       = module.lambda_layers_deploy.layer_arns
}

output "layer_versions" {
  description = "Versions of deployed Lambda layers"
  value       = module.lambda_layers_deploy.layer_versions
}

output "integration_info" {
  description = "Complete integration information"
  value = {
    compiled_zips = module.lambda_layers_builder.compiled_zips
    layer_arns    = module.lambda_layers_deploy.layer_arns
    layer_names   = module.lambda_layers_builder.layer_names
  }
}