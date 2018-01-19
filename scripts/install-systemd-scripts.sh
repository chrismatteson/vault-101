#!/usr/bin/env bash

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

vault_systemd () {
sudo bash -c "cat >${1}/vault.service" << 'EOF'
[Unit]
Description=Vault Agent
Requires=consul-online.target
After=consul-online.target

[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault server -config /etc/vault.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=vault
Group=vault

[Install]
WantedBy=multi-user.target
EOF
}

consul_systemd () {
sudo bash -c "cat >${1}/consul.service" << 'EOF'
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir /etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=consul
Group=consul

[Install]
WantedBy=multi-user.target
EOF
}

consul_online_target () {
sudo bash -c "cat >${1}/consul-online.target" << 'EOF'
[Unit]
Description=Consul Online
RefuseManualStart=true
EOF
}

consul_online_service () {
sudo bash -c "cat >${1}/consul-online.service" << 'EOF'
[Unit]
Description=Consul Online
Requires=consul.service
After=consul.service

[Service]
Type=oneshot
ExecStart=/usr/bin/consul-online.sh
User=consul
Group=consul

[Install]
WantedBy=consul-online.target multi-user.target
EOF
}

consul_online_script () {
sudo bash -c "cat >/usr/bin/consul-online.sh" << 'EOF'
#!/usr/bin/env bash

set -e
set -o pipefail

CONSUL_ADDRESS=${1:-"127.0.0.1:8500"}
# waitForConsulToBeAvailable loops until the local Consul agent returns a 200
# response at the /v1/operator/raft/configuration endpoint.
#
# Parameters:
#     None
function waitForConsulToBeAvailable() {
  local consul_addr=$1
  local consul_leader_http_code

  consul_leader_http_code=$(curl --silent --output /dev/null --write-out "%{http_code}" "${consul_addr}/v1/operator/raft/configuration") || consul_leader_http_code=""

  while [ "x${consul_leader_http_code}" != "x200" ] ; do
    echo "Waiting for Consul to get a leader..."
    sleep 5
    consul_leader_http_code=$(curl --silent --output /dev/null --write-out "%{http_code}" "${consul_addr}/v1/operator/raft/configuration") || consul_leader_http_code=""
  done
}

waitForConsulToBeAvailable "${CONSUL_ADDRESS}"
EOF
}

if [[ ! -z ${YUM} ]]; then
  SYSTEMD_DIR="/etc/systemd/system"
  logger "Installing systemd services for RHEL/CentOS"
elif [[ ! -z ${APT_GET} ]]; then
  SYSTEMD_DIR="/lib/systemd/system"
  logger "Installing systemd services for Debian/Ubuntu"
else
  logger "Service not installed due to OS detection failure"
  exit 1;
fi

vault_systemd ${SYSTEMD_DIR}
consul_systemd ${SYSTEMD_DIR}
consul_online_target ${SYSTEMD_DIR}
consul_online_service ${SYSTEMD_DIR}
consul_online_script
sudo chmod 0664 ${SYSTEMD_DIR}/{vault*,consul*}
sudo chmod 0755 /usr/bin/consul-online.sh
