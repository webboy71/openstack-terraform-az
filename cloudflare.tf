locals {
  ubuntu_tunnel_cname = cloudflare_zero_trust_tunnel_cloudflared.ubuntu_tunnel.id
  vars = {
    tunnel_token = data.cloudflare_zero_trust_tunnel_cloudflared_token.ubuntu_tunnel_token.token
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "ubuntu_tunnel_token" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.ubuntu_tunnel.id
}


resource "cloudflare_zero_trust_tunnel_cloudflared" "ubuntu_tunnel" {
  depends_on = [azurerm_public_ip.my_terraform_public_ip]
  account_id = var.cloudflare_account_id
  #name       = random_pet.cf_name.id
  name       = "cf_tunnel-${random_pet.rg_name.id}"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "ubuntu_tunnel" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.ubuntu_tunnel]
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.ubuntu_tunnel.id
  config = {
    ingress = [
      {
        hostname = "${cloudflare_dns_record.dash.name}"
        service  = "http://${var.private_ip_address}"
        path     = "dashboard"
      },
      {
        service = "http_status:404"
      },
    ]
    connect_timeout = "2m0s"
    warp_routing = {
      enabled = true
    }
  }
}

resource "cloudflare_dns_record" "dash" {
  name    = "dash.${var.domain}"
  ttl     = 1
  type    = "CNAME"
  content = "${local.ubuntu_tunnel_cname}.cfargotunnel.com"
  zone_id = var.cloudflare_zone_id
  proxied = true
}