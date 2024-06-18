provider "google" {
    project = var.projectid
    region = var.tf_region
    credentials = file("creds.json")
}

