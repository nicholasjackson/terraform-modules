#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null


echo "Installing Docker..."
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
sudo apt-get install -y docker-engine


echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

# Setup Consul
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config.json > /dev/null <<EOF
${consul_config}
EOF

sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description = "Consul"

[Service]
# Stop consul will not mark node as failed but left
KillSignal=INT
ExecStart=/usr/local/bin/consul agent -config-dir="/etc/consul.d"
Restart=always
ExecStopPost=sleep 5
EOF


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
sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
${nomad_config}
EOF

sudo tee /etc/systemd/system/nomad.service > /dev/null <<"EOF"
[Unit]
Description = "Nomad"

[Service]
# Stop consul will not mark node as failed but left
KillSignal=INT
ExecStart=/usr/local/bin/nomad agent -config="/etc/nomad.d"
Restart=always
ExecStopPost=sleep 5
EOF


echo "Fetching hashi-ui..."
cd /tmp
curl -sLo hashi-ui \
  https://github.com/jippi/hashi-ui/releases/download/v${hashiui_version}/hashi-ui-linux-amd64
sudo chmod +x hashi-ui
sudo mv hashi-ui /usr/local/bin/hashi-ui

echo "Installing hashi-ui..."
sudo tee /etc/systemd/system/hashi-ui.service > /dev/null <<EOF
[Unit]
description="Hashi UI"

[Service]
KillSignal=INT
ExecStart=/usr/local/bin/hashi-ui
Restart=always
RestartSec=5
Environment=CONSUL_ENABLE=true
Environment=NOMAD_ENABLE=true
ExecStopPost=sleep 10
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl enable nomad.service
sudo systemctl enable hashi-ui.service

sudo systemctl start consul.service
sudo systemctl start nomad.service
sudo systemctl start hashi-ui.service
