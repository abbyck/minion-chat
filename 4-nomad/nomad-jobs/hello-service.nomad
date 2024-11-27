
job "hello-service" {
  datacenters = ["dc1"]

  group "hello-group" {
    network {
      port "http" {
        static = 5000
      }
    }

    task "hello" {
      driver = "docker"

      config {
        image = "your_dockerhub_username/helloservice:latest"
        ports = ["http"]
      }

      service {
        name = "hello-service"
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
