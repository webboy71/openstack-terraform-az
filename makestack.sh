#!/bin/bash
sudo rm /etc/default/keyboard
sudo bash -c 'cat << EOF >> /etc/default/keyboard
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="se"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
EOF'
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git 
sudo deluser stack
sudo rm -rf /opt/stack
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
#sudo -u stack -i
sudo -H -u stack sudo -H -u stack bash -c 'git clone https://opendev.org/openstack/devstack /opt/stack/devstack'
sudo -H -u stack bash -c 'cat << EOF >> /opt/stack/devstack/local.conf
[[local|localrc]]
ADMIN_PASSWORD=tester
DATABASE_PASSWORD=stackdb
RABBIT_PASSWORD=stackqueue
SERVICE_PASSWORD=tester
HOST_IP=10.1.0.4
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
sudo -H -u stack bash -c '/opt/stack/devstack/stack.sh'
echo "done"