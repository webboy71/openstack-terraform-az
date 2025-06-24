#!/bin/bash
exec > >(tee -i /tmp/makestack.log)
exec 2>&1
set -ex
export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt upgrade -y && \
sudo /usr/bin/timedatectl set-timezone UTC
sudo apt-get install -y locales
sudo locale-gen en_US.UTF-8

# Preseed keyboard layout
echo "keyboard-configuration keyboard-configuration/layoutcode select us" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/modelcode select pc105" | debconf-set-selections

sudo apt-get install -y keyboard-configuration console-setup
# Reconfigure package
dpkg-reconfigure -f noninteractive keyboard-configuration

# Optionally apply immediately (for console)
setupcon

# Persist change
service console-setup restart

sudo apt install -y git vim tmux 
#sudo deluser stack
#sudo rm -rf /opt/stack
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
#sudo -u stack -i
sudo -u stack bash -c 'git clone https://opendev.org/openstack/devstack /opt/stack/devstack'
sudo -u stack bash -c 'cat << EOF >> /opt/stack/devstack/local.conf
[[local|localrc]]
ADMIN_PASSWORD=tester
DATABASE_PASSWORD=tester
RABBIT_PASSWORD=tester
SERVICE_PASSWORD=tester
HOST_IP=10.1.0.4
SERVICE_HOST=$HOST_IP
MYSQL_HOST=$HOST_IP
RABBIT_HOST=$HOST_IP
LOGFILE=$DEST/logs/stack.sh.log
LOGDAYS=2
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data

PUBLIC_NETWORK_GATEWAY=172.24.4.1
FLOATING_RANGE=172.24.4.0/24
Q_FLOATING_ALLOCATION_POOL=start=172.24.4.10,end=172.24.4.100
ENABLE_FLOATING_IP=True
Q_USE_PROVIDERNET_FOR_PUBLIC=True
EOF'
#sudo -u stack bash -c '/opt/stack/devstack/stack.sh'
sudo -u stack bash -c 'export HOME=/opt/stack; cd "$HOME"; /opt/stack/devstack/stack.sh'

# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo apt-get update && sudo apt-get install cloudflared && \
sudo cloudflared service install $1

echo "done"
cat /tmp/makestack.log