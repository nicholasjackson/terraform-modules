job "fabio" {
  datacenters = ["dc1"]
  type = "system"

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "web" {

    constraint {
      distinct_hosts = true
    }
    
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "testapp" {
      driver = "docker"

      env = {
        registry.consul.addr="${NOMAD_IP_http}:8500"
      }

      config {
        image = "docker.io/magiconair/fabio:latest"
        port_map {
          http = 9999
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "http" {
            static = "9999"
          }
          port "admin" {
            static = "9998"
          }
        }
      }

      service {
        name = "fabio"
        tags = ["router"]
        port = "admin"

        check {
          name     = "alive"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/health"
        }
      }
    }
  }
}
