###########################################
#   Lambda Layers Builder Module         #
#   Responsible for compiling layers      #
###########################################

locals {
  # Generate consistent layer names following convention: {client}-{project}-{environment}-layer-{map_key}
  layer_names = {
    for k, v in var.layers_config : k => "${var.client}-${var.project}-${var.environment}-layer-${k}"
  }
  
  # Pre-calculate commands for each layer to avoid complex expressions in provisioner
  layer_commands = {
    for k, v in var.layers_config : k => (
      v.script_path != "" && v.script_path != null ? 
        "bash ${v.script_path}" : 
        join(" && ", try(v.commands, []))
    ) if v.type == "compile"
  }
}

# Create layer compilation resources (solo para type = "compile")
resource "null_resource" "layer_compilation" {
  for_each = {
    for name, config in var.layers_config : name => config
    if config.type == "compile"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    # Usar comando pre-calculado en locals
    command = local.layer_commands[each.key]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create archive files for compiled layers
data "archive_file" "compiled_layers" {
  for_each = {
    for name, config in var.layers_config : name => config
    if config.type == "compile"
  }

  type        = "zip"
  source_dir  = each.value.source_dir
  output_path = each.value.filename

  depends_on = [
    null_resource.layer_compilation
  ]
}