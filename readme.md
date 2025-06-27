This Terraform project will create an Ubuntu VM in Azure, install Devstack, create a cloudflared tunnel on Cloudflare, and install cloudflared on the server so that the web interface can be reached via the tunnel.   

NOTE: Devstack doesn't survive reboots well - hence the whole idea with this project. i.e. This is a starting point for being able to spin up an instance of Openstack in Azure  without having to leave an expensive server running 24/7.

Tip: - use this Terraform project for setting up Devstack only, then create another for automating resources on top of Devstack.

Don't forget to copy example.tfvars to terraform.tfvars and fill in the variables for your needs
