
job "response-service" {
  datacenters = ["dc1"]

  group "response-group" {
    network {
      port "http" {
        static = 5001
      }
    }

    task "response" {
      driver = "docker"

      config {
        image = "your_dockerhub_username/responseservice:latest"
        ports = ["http"]
      }

      service {
        name = "response-service"
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
