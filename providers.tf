###########################################
#Version definition - Terraform - Providers
###########################################

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