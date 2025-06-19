terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
# provider configuration 
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "null_resource" "example_provisioner" {
  connection {
    type        = "ssh"
    host        = var.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path) # Path to your private key
  }

  provisioner "file" {
    source      = "local_file.txt"                              # Replace with your source file
    destination = "/home/${var.admin_username}/remote_file.txt" # Destination path on VM
  }
}