variable "devstack_password" {
  description = "Password for devstack passwords (in makestack.sh)"
  type        = string
  #setting sensitive messes up the output.
  #sensitive   = true
  default     = "tester"
}

variable "cloudflare_account_id" {
  description = "ID for the Cloudflare account"
  type        = string
  sensitive   = true
}
variable "admin_username" {
  description = "Username for the admin user on the VM"
  type        = string
  sensitive   = true
  default     = "azureuser"
}
variable "cloudflare_zone_id" {
  description = "Cloudflare zone"
  type        = string
  sensitive   = true
}
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}
variable "domain" {
  description = "Cloudflare domain"
  type        = string
}
variable "hostname" {
  description = "hostname"
  type        = string
}
variable "ssh_private_key_path" {
  description = "Path to the SSH private key for accessing the VM"
  type        = string
  sensitive   = false
}
variable "ssh_public_key_path" {
  description = "Path to the SSH public key for accessing the VM"
  type        = string
  sensitive   = false
}
variable "private_ip_address" {
  description = "private IP address of the VM"
  type        = string
  sensitive   = false
  default    = "10.1.0.4"
}
variable "resource_group_location" {
  description = "value for the location of the resource group"
  type        = string
  sensitive   = false
  default     = "Sweden Central"

}