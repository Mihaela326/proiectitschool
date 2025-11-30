#!/bin/bash

# System Information Monitoring Script (Bash)
# Displays system info every x seconds with critical alerts
# Logs to file with INFO, WARN, ALERT, CRITICAL levels

# Configuration
INTERVAL=${1:-5}  # Default 5 seconds, can be changed via argument

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

LOG_FILE="${LOG_PATH:-${log_path:-/var/log/system-monitor.log}}"  # Log file path from .env or environment

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Critical thresholds
RAM_THRESHOLD=15
DISK_THRESHOLD=90

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create log directory if it doesn't exist
    local log_dir=$(dirname "$LOG_FILE")
    if [ -n "$log_dir" ] && [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null || true
    fi
    
    # Write to log file
    if [ -w "$log_dir" ] || [ -w "$(dirname "$log_dir")" ]; then
        echo "[$timestamp] $(printf '%-8s' "$level"): $message" >> "$LOG_FILE"
    fi
}

clear_screen() {
    clear
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     System Information Monitor${NC}"
    echo -e "${BLUE}========================================${NC}"
}

get_date_time() {
    echo -e "${GREEN}Date and Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    log_message "INFO" "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

get_linux_info() {
    echo -e "${GREEN}Linux Distribution:${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "  OS: $NAME $VERSION"
        echo "  ID: $ID"
        log_message "INFO" "OS: $NAME $VERSION (ID: $ID)"
    else
        log_message "WARN" "OS information not available"
    fi
    echo -e "${GREEN}Kernel:${NC} $(uname -r)"
    log_message "INFO" "Kernel: $(uname -r)"
    echo -e "${GREEN}Hostname:${NC} $(hostname)"
    log_message "INFO" "Hostname: $(hostname)"
}

get_load_average() {
    LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo -e "${GREEN}Load Average:${NC} $LOAD"
    log_message "INFO" "Load Average: $LOAD"
}

get_uptime() {
    UPTIME=$(uptime -p)
    echo -e "${GREEN}Uptime:${NC} $UPTIME"
    log_message "INFO" "Uptime: $UPTIME"
}

get_cpu_usage() {
    # Get average CPU usage over 1 second
    CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    echo -e "${GREEN}CPU Usage:${NC} $CPU"
}

get_memory_usage() {
    echo -e "${GREEN}Memory Usage:${NC}"
    FREE_OUTPUT=$(free -h | grep Mem)
    TOTAL=$(echo $FREE_OUTPUT | awk '{print $2}')
    USED=$(echo $FREE_OUTPUT | awk '{print $3}')
    AVAILABLE=$(echo $FREE_OUTPUT | awk '{print $7}')
    
    # Calculate percentage
    TOTAL_KB=$(echo $FREE_OUTPUT | awk '{print $2}' | sed 's/G/*1024/g; s/M//g; s/K/\/1024/g' | bc -l 2>/dev/null || echo "0")
    USED_KB=$(echo $FREE_OUTPUT | awk '{print $3}' | sed 's/G/*1024/g; s/M//g; s/K/\/1024/g' | bc -l 2>/dev/null || echo "0")
    
    if command -v bc &> /dev/null; then
        MEM_PERCENT=$(free | grep Mem | awk '{printf("%.1f%%", ($3/$2)*100)}')
    else
        MEM_PERCENT=$(free | grep Mem | awk '{printf("%.0f%%", ($3/$2)*100)}')
    fi
    
    echo "  Total: $TOTAL"
    echo "  Used: $USED"
    echo "  Available: $AVAILABLE"
    echo "  Percentage: $MEM_PERCENT"
    log_message "INFO" "Memory Usage: Total=$TOTAL, Used=$USED, Available=$AVAILABLE, Percentage=$MEM_PERCENT"
}

get_disk_usage() {
    echo -e "${GREEN}Disk Usage:${NC}"
    df -h | grep -E "^/dev/" | while read line; do
        USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
        FS=$(echo $line | awk '{print $1}')
        MOUNT=$(echo $line | awk '{print $NF}')
        printf "  %-20s %s / %s (%s)\n" "$FS" "$(echo $line | awk '{print $3}')" "$(echo $line | awk '{print $2}')" "$(echo $line | awk '{print $5}')"
        log_message "INFO" "Disk Usage: $FS = $(echo $line | awk '{print $3}') / $(echo $line | awk '{print $2}') ($(echo $line | awk '{print $5}'))"
    done
}

check_alerts() {
    echo ""
    echo -e "${BLUE}========== ALERTS ==========${NC}"
    
    ALERT_FLAG=0
    
    # Check RAM usage
    MEM_PERCENT=$(free | grep Mem | awk '{printf("%.0f", ($3/$2)*100)}')
    if [ "$MEM_PERCENT" -lt "$RAM_THRESHOLD" ]; then
        echo -e "${RED}[CRITICAL] RAM available: ${MEM_PERCENT}% (threshold: ${RAM_THRESHOLD}%)${NC}"
        log_message "CRITICAL" "RAM available: ${MEM_PERCENT}% (threshold: ${RAM_THRESHOLD}%)"
        ALERT_FLAG=1
    fi
    
    # Check Disk usage
    DISK_CRITICAL=$(df -h | grep -E "^/dev/" | awk '{print $5}' | sed 's/%//' | awk -v thresh="$DISK_THRESHOLD" '$1 > thresh {print 1}' | head -1)
    if [ "$DISK_CRITICAL" = "1" ]; then
        echo -e "${RED}[CRITICAL] Disk usage over ${DISK_THRESHOLD}%${NC}"
        df -h | grep -E "^/dev/" | awk -v thresh="$DISK_THRESHOLD" '{print $5}' | sed 's/%//' | awk -v thresh="$DISK_THRESHOLD" '$1 > thresh {print "  " $1 "%"}' | while read line; do
            echo -e "${RED}$line${NC}"
            log_message "CRITICAL" "Disk usage: $line"
        done
        ALERT_FLAG=1
    fi
    
    if [ $ALERT_FLAG -eq 0 ]; then
        echo -e "${GREEN}No critical alerts${NC}"
        log_message "INFO" "No critical alerts"
    fi
    
    echo -e "${BLUE}===========================${NC}"
}

# Main loop
echo "Starting system monitor (refreshing every ${INTERVAL} seconds)..."
sleep 2

while true; do
    clear_screen
    print_header
    echo ""
    
    get_date_time
    echo ""
    
    get_linux_info
    echo ""
    
    get_load_average
    echo ""
    
    get_uptime
    echo ""
    
    get_cpu_usage
    echo ""
    
    get_memory_usage
    echo ""
    
    get_disk_usage
    echo ""
    
    check_alerts
    
    echo ""
    echo -e "${YELLOW}Next update in ${INTERVAL} seconds (press Ctrl+C to exit)...${NC}"
    
    sleep $INTERVAL
done
