#!/bin/bash -xe

# 1. Download Consul
apt install unzip
wget https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
unzip consul_${consul_version}_linux_amd64.zip
chmod +x consul
mv consul /usr/local/bin

# 2. Consul settings
mkdir -p /etc/consul/data

cat > /etc/consul/conf.json << '__EOF_CONSUL_CONFIG'
${consul_config}
__EOF_CONSUL_CONFIG

cat > /usr/lib/systemd/system/consul.service << '__EOF_CONSUL_SERVICE'
${consul_service}
__EOF_CONSUL_SERVICE

systemctl enable consul
systemctl start consul
