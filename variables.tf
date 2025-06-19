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
variable "ssh_private_key_path" {
  description = "Path to the SSH private key for accessing the VM"
  type        = string
  sensitive   = false
}
variable "public_ip_address" {
  description = "Public IP address of the VM"
  type        = string
  sensitive   = false
}