# Display's the VM's public and private IP

output "jenkins_master_private_ip" {
    value = {
        for instance in google_compute_instance.tf-vm-instances :
        instance.name => {
            private_ip  = instance.network_interface[0].network_ip
            public_ip = instance.network_interface[0].access_config[0].nat_ip
        }
    }
  
}