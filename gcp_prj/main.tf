
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "confidential-vm-images/ubuntu-pro-fips-2004-focal-v20230302"
    }
  }
   scheduling {
    on_host_maintenance = "TERMINATE"
  }
   confidential_instance_config {
    enable_confidential_compute = true
  }   
  # Install Flask Web Server
  metadata_startup_script = file("apache_web.sh")

  tags=["web"]
  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  auto_create_subnetworks = "true"
}
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  network = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["web"]

 allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
  
}