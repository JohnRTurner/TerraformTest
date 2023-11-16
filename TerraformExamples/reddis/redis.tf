# Redis service

resource "aiven_redis" "single-node-aiven-redis" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "startup-4"
  service_name            = "aws-single-node-redis1"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"

  redis_user_config {
    redis_maxmemory_policy = "allkeys-random"

    public_access {
      redis = true
    }
  }
}