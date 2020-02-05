job "homeassistant" {
  datacenters = ["alpha"]
  type = "service"
  update {
    max_parallel = 2
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  migrate {
    max_parallel = 2
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }
  group "homeassistant" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "homeassistant_core" {
      driver = "docker"
      config {
        image = "homeassistant/home-assistant"
        network_mode = "bridge"
        volumes = [
            "/srv/home_assistant/config:/config",
            "/etc/localtime:/etc/localtime:ro"
        ]
        port_map {
          homeassistant_core = 8123
        }
        labels {
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 1024 # 1G
        network {
          mbits = 100
          port "homeassistant_core" {}
        }
      }
      service {
        name = "homeassistant"
        port = "homeassistant_core"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
