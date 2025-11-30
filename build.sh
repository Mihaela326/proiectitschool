#!/bin/bash

# Build script for both Docker images

echo "======================================"
echo "Building Docker Images"
echo "======================================"
echo ""

# Build Bash-based image
echo "[1/2] Building Bash monitoring image..."
docker build -f Dockerfile.bash -t system-monitor-bash:latest .

if [ $? -eq 0 ]; then
    echo "✓ Bash image built successfully"
else
    echo "✗ Failed to build Bash image"
    exit 1
fi

echo ""

# Build Python-based image
echo "[2/2] Building Python monitoring image..."
docker build -f Dockerfile.python -t system-monitor-python:latest .

if [ $? -eq 0 ]; then
    echo "✓ Python image built successfully"
else
    echo "✗ Failed to build Python image"
    exit 1
fi

echo ""
echo "======================================"
echo "Build completed successfully!"
echo "======================================"
echo ""
echo "Images created:"
echo "  - system-monitor-bash:latest"
echo "  - system-monitor-python:latest"
echo ""
echo "To run containers:"
echo "  Bash:   docker run -v monitoring-logs-bash:/var/log --name monitor-bash system-monitor-bash:latest"
echo "  Python: docker run -v monitoring-logs-python:/var/log --name monitor-python system-monitor-python:latest"
