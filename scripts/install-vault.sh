#!/usr/bin/env bash

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"


VAULT_VERSION="0.10.0.0"
VAULT_ZIP="vault-enterprise_${VAULT_VERSION}%2Bent_linux_amd64.zip"
VAULT_URL=${URL:-"https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/vault/ent/${VAULT_VERSION}/${VAULT_ZIP}"}

logger "Downloading vault ${VAULT_VERSION}"
curl --silent --output /tmp/${VAULT_ZIP} ${VAULT_URL}

logger "Installing vault"
sudo unzip -o /tmp/${VAULT_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/vault
sudo chown vault:vault /usr/local/bin/vault
sudo mkdir -pm 0755 /etc/vault.d
sudo mkdir -pm 0755 /etc/ssl/vault

logger "/usr/local/bin/vault --version: $(/usr/local/bin/vault --version)"

logger "Configuring vault ${VAULT_VERSION}"
sudo chown -R vault:vault /etc/vault.d /etc/ssl/vault
sudo chmod -R 0644 /etc/vault.d/*
echo "export VAULT_ADDR=http://127.0.0.1:8200" | sudo tee /etc/profile.d/vault.sh

logger "Complete"
