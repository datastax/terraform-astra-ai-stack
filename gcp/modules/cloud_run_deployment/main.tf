locals {
  service_name = "${var.container_info.name}-service"
}

resource "google_cloud_run_v2_service" "this" {
  name     = local.service_name
  project  = var.infrastructure.project_id
  location = var.infrastructure.location

  template {
    containers {
      image   = var.container_info.image
      command = var.container_info.entrypoint

      liveness_probe {
        http_get {
          path = var.container_info.health_path
        }
        initial_delay_seconds = 60
      }

      resources {
        limits = {
          cpu    = try(coalesce(var.config.containers.cpu), "1")
          memory = try(coalesce(var.config.containers.memory), "2048Mi")
        }
      }

      ports {
        container_port = var.container_info.port
        name           = "http1"
      }

      dynamic "env" {
        for_each = coalesce(var.container_info.env, {})

        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }

    scaling {
      min_instance_count = try(var.config.containers.min_instances, 0)
      max_instance_count = try(var.config.containers.max_instances, 20)
    }
  }

  ingress = var.config.domain != null ? "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" : "INGRESS_TRAFFIC_ALL"
}

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.this.location
  project  = google_cloud_run_v2_service.this.project
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_name" {
  value = local.service_name
}

output "service_uri" {
  value = google_cloud_run_v2_service.this.uri
}
