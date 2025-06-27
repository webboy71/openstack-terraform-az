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
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# provider configuration 
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
provider "azurerm" {
  features {}
}

resource "null_resource" "ubuntu_openstack_provisioner" {
  connection {
    type = "ssh"
    #host        = var.public_ip_address
    host        = azurerm_public_ip.openstack_public_ip.ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path) # Path to your private key
  }



  provisioner "file" {
    source      = "makestack.sh"
    destination = "/home/azureuser/makestack.sh"
  }
  provisioner "remote-exec" {

    inline = [
      #"export TUN_TOKEN=${data.cloudflare_zero_trust_tunnel_cloudflared_token.ubuntu_tunnel_token.token}",
      "chmod +x /home/azureuser/makestack.sh",
      "sudo /home/azureuser/makestack.sh ${data.cloudflare_zero_trust_tunnel_cloudflared_token.ubuntu_tunnel_token.token} ${var.devstack_password} ${var.private_ip_address}",
      "grep -q \"CSRF_TRUSTED_ORIGINS\" /opt/stack/horizon/openstack_dashboard/local/local_settings.py || \\",
      "echo \"CSRF_TRUSTED_ORIGINS = [\\\"https://${var.hostname}.${var.domain}\\\"]\" | sudo tee -a /opt/stack/horizon/openstack_dashboard/local/local_settings.py > /dev/null",
      "sudo systemctl restart apache2"
    ]
  }
}