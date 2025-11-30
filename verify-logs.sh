#!/bin/bash

# Script to verify logs from both containers

echo "======================================"
echo "Verifying Container Logs"
echo "======================================"
echo ""

# Check if containers are running
echo "Checking container status..."
bash_running=$(docker ps --filter "name=monitor-bash" --format "{{.Names}}" | grep -c "monitor-bash" || echo 0)
python_running=$(docker ps --filter "name=monitor-python" --format "{{.Names}}" | grep -c "monitor-python" || echo 0)

echo ""
if [ "$bash_running" -eq 1 ]; then
    echo "✓ Bash container is running"
else
    echo "✗ Bash container is not running"
fi

if [ "$python_running" -eq 1 ]; then
    echo "✓ Python container is running"
else
    echo "✗ Python container is not running"
fi

echo ""
echo "======================================"
echo "BASH Container Logs (last 30 lines)"
echo "======================================"
docker logs monitor-bash 2>/dev/null | tail -30 || echo "No logs available"

echo ""
echo "======================================"
echo "PYTHON Container Logs (last 30 lines)"
echo "======================================"
docker logs monitor-python 2>/dev/null | tail -30 || echo "No logs available"

echo ""
echo "======================================"
echo "Log Files in Volumes"
echo "======================================"
echo ""
echo "Bash container log volume:"
docker run --rm -v monitoring-logs-bash:/var/log alpine cat /var/log/system-monitor.log 2>/dev/null | tail -20 || echo "No log file found"

echo ""
echo "Python container log volume:"
docker run --rm -v monitoring-logs-python:/var/log alpine cat /var/log/system-monitor.log 2>/dev/null | tail -20 || echo "No log file found"
