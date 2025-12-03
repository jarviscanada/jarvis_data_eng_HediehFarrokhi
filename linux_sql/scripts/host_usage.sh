#!/bin/bash

# Usage: ./host_usage.sh psql_host psql_port db_name psql_user psql_password

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Validate args
if [ "$#" -ne 5 ]; then
  echo "Usage: $0 psql_host psql_port db_name psql_user psql_password"
  exit 1
fi

# Timestamp (UTC)
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")

# Get host_id from host_info using hostname
hostname=$(hostname -f)
export PGPASSWORD=$psql_password
host_id=$(psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -t -A -c "SELECT id FROM host_info WHERE hostname='$hostname';")

# If host_id is empty, exit (host_info.sh might not have been run)
if [ -z "$host_id" ]; then
  echo "Error: host_id not found for hostname $hostname"
  exit 1
fi

# Collect usage data
memory_free=$(free -m | awk '/Mem:/ {print $4}')

vmstat_out=$(vmstat 1 2 | tail -1)
cpu_idle=$(echo "$vmstat_out" | awk '{print $15}')
cpu_kernel=$(echo "$vmstat_out" | awk '{print $14}')
disk_io=$(echo "$vmstat_out" | awk '{print $9}')

disk_available=$(df -m / | tail -1 | awk '{print $4}')

# Build INSERT statement
insert_stmt="INSERT INTO host_usage(\"timestamp\", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# Execute INSERT
psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -c "$insert_stmt"

exit $?
