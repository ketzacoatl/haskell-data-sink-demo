job "demo" {
  region      = "${region}"
  datacenters = ["${datacenters}"]
  type        = "service"

  group "web-service" {
    count = ${count}

    task "demo-web-service" {
      driver = "docker"

      config {
        image   = "${image}"
        command = []
      }

      service {
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = ${cpu_limit}
        memory = ${mem_limit}

        network {
          mbits = ${net_limit}

          port "http" {}
        }
      }
    }
  }
}

