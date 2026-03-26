# Bash Service Health Monitor

## Overview
Monitors system services, attempts recovery, and logs results.

## Features
- Reads services from services.txt
- Detects failures using systemctl
- Auto-restarts services
- Logs events to /var/log/health_monitor.log
- Summary report
- Dry-run mode

## Run
```bash
./monitor.sh
./monitor.sh --dry-run
