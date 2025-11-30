#!/bin/bash

# Run script for both Docker containers

echo "======================================"
echo "Launching Docker Containers"
echo "======================================"
echo ""

# Create volumes if they don't exist
echo "Creating Docker volumes..."
docker volume create monitoring-logs-bash 2>/dev/null || true
docker volume create monitoring-logs-python 2>/dev/null || true

echo ""

# Run Bash-based container
echo "[1/2] Starting Bash monitoring container..."
docker run -d \
    -v monitoring-logs-bash:/var/log \
    --name monitor-bash \
    --restart unless-stopped \
    system-monitor-bash:latest

if [ $? -eq 0 ]; then
    echo "✓ Bash container started (ID: monitor-bash)"
else
    echo "✗ Failed to start Bash container"
    exit 1
fi

echo ""

# Run Python-based container
echo "[2/2] Starting Python monitoring container..."
docker run -d \
    -v monitoring-logs-python:/var/log \
    --name monitor-python \
    --restart unless-stopped \
    system-monitor-python:latest

if [ $? -eq 0 ]; then
    echo "✓ Python container started (ID: monitor-python)"
else
    echo "✗ Failed to start Python container"
    exit 1
fi

echo ""
echo "======================================"
echo "Containers launched successfully!"
echo "======================================"
echo ""
echo "Running containers:"
docker ps --filter "name=monitor-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""
echo "View logs:"
echo "  Bash:   docker logs -f monitor-bash"
echo "  Python: docker logs -f monitor-python"
echo ""
echo "Stop containers:"
echo "  Bash:   docker stop monitor-bash"
echo "  Python: docker stop monitor-python"
echo ""
echo "Remove containers:"
echo "  docker rm monitor-bash monitor-python"
