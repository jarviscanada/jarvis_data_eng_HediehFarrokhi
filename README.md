# Linux Cluster Monitoring Agent

## ? Overview
This project collects hardware information and real-time resource usage from a Linux VM and stores it in a PostgreSQL database. The goal is to simulate a monitoring agent that helps track cluster node performance.

## ?? Features
### `host_info.sh`
- Collects static hardware specs: hostname, CPU model, memory, architecture.
- Constructs an SQL INSERT statement dynamically.
- Inserts data into the `host_info` table.
- Runs **once** to register the host machine.

### `host_usage.sh`
- Collects real-time usage metrics every minute:
  - free memory
  - CPU idle %
  - CPU kernel %
  - disk I/O
  - disk available
- Inserts metrics into `host_usage` table.
- Automated using **crontab**.

## ? Crontab Automation
The monitoring agent runs every minute via:

```bash
* * * * * bash /home/hediefarrokhi/dev/jarvis_data_eng_hedieh/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log 2>&1
