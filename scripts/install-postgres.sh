#!/usr/bin/env bash

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

sudo yum install postgresql-server -y"
echo 'hashicorp!' | sudo passwd --stdin postgres"
sudo postgresql-setup initdb
sudo echo 'host    all             all             0.0.0.0/0               trust' > /var/lib/pgsql/data/pg_hba.conf
sudo echo 'listen_addresses = '\''*'\' >> /var/lib/pgsql/data/postgresql.conf

logger "Complete"
