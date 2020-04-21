job "sonarrsync" {
  datacenters = ["alpha"]
  type        = "service"

  update {
    max_parallel      = 2
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = false
    canary            = 0
  }

  migrate {
    max_parallel     = 2
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "sonarrsync" {
    count = 1

    volume "sonarrsyncconfig" {
      type      = "host"
      read_only = false
      source    = "sonarrsyncconfig"
    }

    volume "tvfolder" {
      type      = "host"
      read_only = false
      source    = "tvfolder"
    }

    volume "tvsync" {
      type      = "host"
      read_only = false
      source    = "tvsync"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size    = 200
      sticky  = true
      migrate = true
    }

    task "sonarrsync" {
      driver = "docker"

      volume_mount {
        volume      = "sonarrsyncconfig"
        destination = "/config"
        read_only   = false
      }

      volume_mount {
        volume      = "tvfolder"
        destination = "/tv"
        read_only   = false
      }

      volume_mount {
        volume      = "tvsync"
        destination = "/downloads"
        read_only   = false
      }


      config {
        image        = "linuxserver/syncthing"
        network_mode = "bridge"

        port_map {
          sonarrsync = 8384
        }

        labels {}
      }

      env {
        PUID = "1000"
        PGID = "995"
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 1024 # 1G

        network {
          mbits = 100
          port  "sonarrsync"{}
        }
      }

      service {
        name = "sonarrsync"
        port = "sonarrsync"

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
