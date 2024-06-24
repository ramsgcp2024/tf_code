variable "projectid" {
    default = "instant-droplet-410306"
}

variable "tf_region" {
    default = "us-west4"
}

variable "vpc_name" {
  default = "i27-ecommorce-vpc"
}

variable "cidr" {
  default = "10.1.0.0/16"
}

variable "firwall_name" {
  default = "i27-firewall"
}

variable "ports" {
  default = [80, 8080, 8081, 9000, 22]
}

variable "instances" {
  default = {
    "jenkins-master" = {  
      instance_type = "e2-medium" 
      zone = "us-west4-a"
    }
    "jenkins-slave" = {
      instance_type = "n1-standard-1"
      zone = "us-west4-b"
    }
    "ansible" = {
      instance_type = "e2-medium"
      zone = "us-west4-a"
    }
     "sonarqube" = {
      instance_type = "e2-medium"
      zone = "us-west4-a"
    }
  }   
}

variable "vm_user" {
  default = "ramsgcp23"
}
