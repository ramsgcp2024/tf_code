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

#Generate SSH key-pair
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA" 
  rsa_bits = 2048
}

# Save the private key in local file

resource "local_file" "private_key" {
  content = tls_private_key.ssh-key.private_key_pem
  filename = "${path.module}/id_rsa"
}

# Save the public key in local file

resource "local_file" "public_key" {
  content = tls_private_key.ssh-key.public_key_pem
  filename = "${path.module}/id_rsa.pub"
}

# This will create compute engine instances
resource "google_compute_instance" "tf-vm-instances" {
  for_each = var.instances
  name = each.key
  zone = each.value.zone
  machine_type = each.value.instance_type
  tags = [each.key]

  # We have copied from console while creating VM it shows as "Equalent command line"
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

metadata = {
  ssh-keys = "${var.vm_user}:${tls_private_key.ssh-key.public_key_openssh}"
}
connection {
  type = "ssh"
  user = var.vm_user
  host = self.network_interface[0].access_config[0].nat_ip
  private_key = tls_private_key.ssh-key.private_key_pem
}

# Provisioner ["remote-exec","local-exec","file"]

provisioner "file" {
  source = each.key == "ansible" ? "ansible.sh" : "other.sh"
  destination = each.key == "ansible" ? "/home/${var.vm_user}/ansible.sh" : "/home/${var.vm_user}/other.sh"
}

provisioner "remote-exec" {
  inline = [ 
    each.key == "ansible" ? "chmod +x /home/${var.vm_user}/ansible.sh && sh /home/${var.vm_user}/ansible.sh" : "echo 'Skipping the Command!!!!'"
   ]
}
}

# data block to get images
data "google_compute_image" "ubuntu_image" {
    family = "ubuntu-2004-lts"
    project = "ubuntu-os-cloud"
}

