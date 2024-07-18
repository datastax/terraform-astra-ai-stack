locals {
  container_info = {
    name        = "langflow"
    image       = "langflowai/langflow:${coalesce(var.config.version, "latest")}"
    port        = 7860
    env         = var.config.env
    health_path = "/health"
  }
}

output "container_info" {
  value = local.container_info
}

output "fqdn" {
  value = module.container_app_deployment.fqdn
}

output "id" {
  value = module.container_app_deployment.id
}

output "domain_verification_id" {
  value = module.container_app_deployment.domain_verification_id
}

module "container_app_deployment" {
  source         = "../container_app_deployment"
  container_info = local.container_info
  config         = var.config
  infrastructure = var.infrastructure
}
