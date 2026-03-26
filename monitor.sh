#!/bin/bash

LOG_FILE="/var/log/health_monitor.log"
SERVICE_FILE="services.txt"
DRY_RUN=false

# Check for --dry-run flag
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[INFO] Running in DRY-RUN mode (no actual restart)"
fi

# Handle missing or empty services file
if [[ ! -f "$SERVICE_FILE" ]]; then
    echo "[ERROR] services.txt not found!"
    exit 1
fi

if [[ ! -s "$SERVICE_FILE" ]]; then
    echo "[ERROR] services.txt is empty!"
    exit 1
fi

# Counters
total=0
healthy=0
recovered=0
failed=0

# Logging function
log_event() {
    local level=$1
    local service=$2
    local message=$3
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] [$service] $message" >> "$LOG_FILE"
}

echo "User: $(whoami) | Host: $(hostname)"
echo "--------------------------------------"

# Process each service
while read -r service; do
    ((total++))
    
    status=$(systemctl is-active "$service" 2>/dev/null)

    if [[ "$status" == "active" ]]; then
        echo "$service : HEALTHY"
        ((healthy++))
    else
        echo "$service : DOWN → Attempting restart..."

        if [[ "$DRY_RUN" == false ]]; then
            systemctl restart "$service"
        fi

        sleep 5
        status=$(systemctl is-active "$service" 2>/dev/null)

        if [[ "$status" == "active" ]]; then
            echo "$service : RECOVERED"
            log_event "INFO" "$service" "RECOVERED"
            ((recovered++))
        else
            echo "$service : FAILED"
            log_event "ERROR" "$service" "FAILED"
            ((failed++))
        fi
    fi

done < "$SERVICE_FILE"

# Summary Table
echo ""
echo "========= SUMMARY ========="
printf "Total Checked : %d\n" "$total"
printf "Healthy       : %d\n" "$healthy"
printf "Recovered     : %d\n" "$recovered"
printf "Failed        : %d\n" "$failed"
echo "==========================="
