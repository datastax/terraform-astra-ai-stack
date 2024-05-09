module "assistants_api_db" {
  source         = "../astra_db"
  cloud_provider = var.cloud_provider

  config = {
    name                = "assistant_api_db"
    keyspace            = "assistant_api"
    regions             = var.config.db.regions
    deletion_protection = try(coalesce(var.config.db.deletion_protection), null)
    cloud_provider      = try(coalesce(var.config.db.cloud_provider), null)
  }
}

locals {
  container_info = {
    name  = "astra-assistants"
    image = "datastax/astra-assistants:v0.1.18"
    port  = 8000
    health_path = "v1/health"
  }
}

output "container_info" {
  value = local.container_info
}

output "target_id" {
  value = module.ecs_deployment.target_id
}

module "ecs_deployment" {
  source         = "../ecs_deployment"
  infrastructure = var.infrastructure
  config         = var.config
  container_info = local.container_info
}