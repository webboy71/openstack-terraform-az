#!/bin/bash

# Redirect output to a log file
exec > >(tee -i /tmp/makestack.log)
exec 2>&1
set -ex
IP_ADD=$2
# skip installing stuff with interactive keyboard configuration triggers since it breaks the script
sudo apt-mark hold keyboard-configuration
sudo apt-mark hold console-setup

# Set global keyboard layout configuration on Debian/Ubuntu

# --- CONFIGURE THIS SECTION ---
KEYBOARD_MODEL="pc105"
KEYBOARD_LAYOUT="se"
KEYBOARD_VARIANT=""
KEYBOARD_OPTIONS=""
# ------------------------------

echo "Setting keyboard configuration to:"
echo "  Model:   $KEYBOARD_MODEL"
echo "  Layout:  $KEYBOARD_LAYOUT"
echo "  Variant: $KEYBOARD_VARIANT"
echo "  Options: $KEYBOARD_OPTIONS"

# Update /etc/default/keyboard
sudo tee /etc/default/keyboard > /dev/null <<EOF
XKBMODEL="$KEYBOARD_MODEL"
XKBLAYOUT="$KEYBOARD_LAYOUT"
XKBVARIANT="$KEYBOARD_VARIANT"
XKBOPTIONS="$KEYBOARD_OPTIONS"
EOF

# Apply the new keyboard settings
echo "Applying new keyboard configuration..."
sudo setupcon
sudo systemctl restart keyboard-setup.service || echo "keyboard-setup.service not found; continuing..."
echo "Keyboard configuration updated successfully."

export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt upgrade -y && \
sudo /usr/bin/timedatectl set-timezone UTC
sudo apt-get install -y locales
sudo locale-gen en_US.UTF-8

sudo apt install -y git vim tmux 

#create stack user if it does not exist
if ! id "stack" &>/dev/null; then
  sudo useradd -s /bin/bash -d /opt/stack -m stack
  echo "User 'stack' created."
else
  echo "User 'stack' already exists. Skipping creation."
fi

sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
echo "################ NOW I AM USER stack ################"
sudo -u stack bash -c 'export DEBIAN_FRONTEND=noninteractive'

sudo -u stack bash -c 'git clone https://opendev.org/openstack/devstack /opt/stack/devstack'
sudo -u stack bash -c "cat << EOF >> /opt/stack/devstack/local.conf
[[local|localrc]]
ADMIN_PASSWORD=tester
DATABASE_PASSWORD=tester
RABBIT_PASSWORD=tester
SERVICE_PASSWORD=tester
HOST_IP=$IP_ADD
SERVICE_HOST=$IP_ADD
SERVICE_HOST=$IP_ADD
SERVICE_HOST=$IP_ADD
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
EOF"

#sudo -u stack bash -c '/opt/stack/devstack/stack.sh'
sudo -u stack bash -c 'export HOME=/opt/stack;export DEBIAN_FRONTEND=noninteractive; cd "$HOME"; /opt/stack/devstack/stack.sh'

# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo apt-get update && sudo apt-get install cloudflared && \
sudo cloudflared service install $1

echo "done"

exit 0