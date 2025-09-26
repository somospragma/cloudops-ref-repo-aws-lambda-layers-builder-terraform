###########################################
################ Outputs ##################
###########################################

###########################################
######### Compiled ZIPs Information #######
###########################################

output "compiled_zips" {
  description = "Map of compiled ZIP files with paths and hashes for use in lambda-layers module"
  value = {
    for k, v in data.archive_file.compiled_layers : k => {
      path = v.output_path
      hash = v.output_base64sha256
      size = v.output_size
    }
  }
}

output "layer_names" {
  description = "Map of layer configuration keys to their generated AWS Lambda Layer names"
  value = local.layer_names
}

###########################################
########## Summary Information ############
###########################################

output "summary" {
  description = "Summary of layers compiled by this module"
  value = {
    total_layers_compiled = length(data.archive_file.compiled_layers)
    layer_names = keys(data.archive_file.compiled_layers)
    zip_files = {
      for k, v in data.archive_file.compiled_layers : k => {
        filename = v.output_path
        size_mb = floor(v.output_size / 1024 / 1024 * 100) / 100
      }
    }
  }
}

output "build_info" {
  description = "Build information for debugging and validation"
  value = {
    for k, v in var.layers_config : k => {
      build_method = v.script_path != "" ? "script" : "commands"
      build_source = v.script_path != "" ? v.script_path : join(" && ", v.commands)
      output_path = v.filename
      source_dir = v.source_dir
    } if v.type == "compile"
  }
}