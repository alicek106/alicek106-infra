#!/bin/bash -xe

# 1. consul agent install
apt install unzip
wget https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
unzip consul_${consul_version}_linux_amd64.zip
chmod +x consul
mv consul /usr/local/bin

# 2. consul agent settings
mkdir -p /etc/consul/data

cat > /etc/consul/conf.json << '__EOF_CONSUL_CONFIG'
${consul_config}
__EOF_CONSUL_CONFIG

cat > /usr/lib/systemd/system/consul.service << '__EOF_CONSUL_SERVICE'
${consul_service}
__EOF_CONSUL_SERVICE

# 3. vault install
wget https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip
unzip vault_${vault_version}_linux_amd64.zip
chmod +x vault
mv vault /usr/local/bin

# 4. vault settings
mkdir -p /etc/vault

cat > /etc/vault/conf.hcl << '__EOF_VAULT_CONFIG'
${vault_config}
__EOF_VAULT_CONFIG

cat > /usr/lib/systemd/system/vault.service << '__EOF_VAULT_SERVICE'
${vault_service}
__EOF_VAULT_SERVICE

# 5. Change NODE_PRIVATE_IP to real ip
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sed -i 's/NODE_PRIVATE_IP/'"$PRIVATE_IP"'/g' /etc/vault/conf.hcl
sed -i 's/NODE_PRIVATE_IP/'"$PRIVATE_IP"'/g' /etc/consul/conf.json

# 6. Start end enable vault/consul
systemctl enable vault
systemctl start vault

systemctl enable consul
systemctl start consul

# 7. Misc
echo "VAULT_ADDR=http://127.0.0.1:8200" >> /etc/environment

## After that, you should execute below commands.
# vault operator init
## And store recovery keys and root key
