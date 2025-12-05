#!/bin/bash

# Usage: ./host_info.sh psql_host psql_port db_name psql_user psql_password

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of arguments
if [ "$#" -ne 5 ]; then
  echo "Usage: $0 psql_host psql_port db_name psql_user psql_password"
  exit 1
fi

# Collect hardware info
hostname=$(hostname -f)
cpu_number=$(lscpu | egrep "^CPU\(s\):" | awk '{print $2}')
cpu_architecture=$(lscpu | egrep "^Architecture:" | awk '{print $2}')
cpu_model=$(lscpu | egrep "^Model name:" | sed 's/Model name:\s*//')
# CPU MHz: your VM doesn't show this, so fallback to 0 if empty
cpu_mhz=$(lscpu | awk -F: '/CPU MHz/ {print $2}' | xargs)
if [ -z "$cpu_mhz" ]; then cpu_mhz=0; fi
# L2 cache: e.g., '1 MiB (1 instance)' ? take just '1'
l2_cache=$(lscpu | awk -F: '/L2 cache/ {print $2}' | awk '{print $1}')

total_mem=$(grep "^MemTotal:" /proc/meminfo | awk '{print $2}')
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")
# Build INSERT statement
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, \"timestamp\")
VALUES('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp');"

# Execute INSERT
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -c "$insert_stmt"

exit $?
