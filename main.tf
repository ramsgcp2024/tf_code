#create VPC

resource "google_compute_network" "tf-vpc" {
  name = var.vpc_name
  auto_create_subnetworks = false
}

# Create subnetwork under the us-central1

resource "google_compute_subnetwork" "tf-subnet" {
    name = "${var.vpc_name}-subnet"
    network = google_compute_network.tf-vpc.name
    region = var.tf_region
    ip_cidr_range = var.cidr
}

resource "google_compute_firewall" "tf-allow-ports" {
  name = var.firwall_name
  network = google_compute_network.tf-vpc.name
  dynamic "allow" {
    for_each = var.ports
    content {
      protocol = "tcp"
      ports = [allow.value]
    }
  }
  source_ranges = ["0.0.0.0/0"]
}

# This will create compute engine instances
resource "google_compute_instance" "tf-vm-instances" {
  for_each = var.instances
  name = each.key
  zone = each.value.zone
  machine_type = each.value.instance_type
  tags = [each.key]
    boot_disk {
    device_name = "instance-20240618-165751"

    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
      size  = 10
      type  = "pd-balanced"
    }
  }
    network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    network = google_compute_network.tf-vpc.name
    subnetwork = google_compute_subnetwork.tf-subnet.name
  }
}

# data block to get images
data "google_compute_image" "ubuntu_image" {
    family = "ubuntu-2004-lts"
    project = "ubuntu-os-cloud"
}