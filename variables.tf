###########################################
####### Lambda Layers Builder ###########
###########################################

variable "layers_config" {
  description = "Map of Lambda layers to compile"
  type = map(object({
    # Identificación
    description = optional(string, "Lambda layer")
    
    # Tipo de compilación: compile (otros tipos son manejados por el módulo principal)
    type = string
    
    # Opción 1: Para compilación con archivo script
    script_path = optional(string, "")
    
    # Opción 2: Para compilación con comandos directos (Backstage)
    commands = optional(list(string), [])
    
    # Configuración de salida (requerida para ambas opciones)
    source_dir = string  # Directorio creado por el script/comandos
    filename   = string  # ZIP de salida
    
    # Configuración AWS (para referencia, no usada en builder)
    runtime      = optional(string, "nodejs22.x")
    architecture = optional(string, "x86_64")
    
    # Etiquetas específicas del layer (para referencia)
    additional_tags = optional(map(string), {})
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.layers_config : contains(["compile"], v.type)
    ])
    error_message = "Builder module only handles layers with type = 'compile'"
  }
  
  validation {
    condition = alltrue([
      for k, v in var.layers_config : 
      v.type == "compile" ? (
        # Debe tener script_path XOR commands (no ambos, no ninguno)
        (v.script_path != "" && length(v.commands) == 0) ||
        (v.script_path == "" && length(v.commands) > 0)
      ) : true
    ])
    error_message = "Para layers tipo 'compile': debe especificar script_path O commands, no ambos ni ninguno"
  }
  
  validation {
    condition = alltrue([
      for k, v in var.layers_config : 
      v.source_dir != "" && v.filename != ""
    ])
    error_message = "source_dir y filename son requeridos para todas las layers"
  }
}

###########################################
####### Sistema de Etiquetado ############
###########################################

variable "client" {
  description = "Client name for resource naming and tagging"
  type        = string
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource naming and tagging"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}