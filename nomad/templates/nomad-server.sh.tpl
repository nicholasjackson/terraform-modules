#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null

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


sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl enable nomad.service

sudo systemctl start consul.service
sudo systemctl start nomad.service


# Start the fabio system job
echo "Submitting fabio job..."
sudo tee /tmp/fabio.hcl > /dev/null <<"EOF"
${fabio_job}
EOF

until nomad run /tmp/fabio.hcl; do
  echo "Job failed to submit..."
  sleep 2
done
