#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null

echo "Fetching Nomad..."
cd /tmp
curl -sLo nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip

echo "Installing Nomad..."
unzip nomad.zip >/dev/null
sudo chmod +x nomad
sudo mv nomad /usr/local/bin/nomad

# Setup Nomad
sudo mkdir -p /mnt/nomad
sudo mkdir -p /etc/nomad.d
sudo tee /etc/nomad.d/server.hcl > /dev/null <<EOF
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/server1"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}
EOF

sudo tee /etc/init/nomad.conf > /dev/null <<"EOF"
description "Nomad"
start on runlevel [2345]
stop on runlevel [06]
respawn
post-stop exec sleep 5
# This is to avoid Upstart re-spawning the process upon `consul leave`
normal exit 0 INT
# Stop consul will not mark node as failed but left
kill signal INT
exec /usr/local/bin/nomad agent \
  -config-dir="/etc/nomad.d"
EOF

sudo service nomad stop || true
sudo service nomad start
