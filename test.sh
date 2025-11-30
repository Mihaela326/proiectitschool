#!/bin/bash

# Comprehensive Docker testing and verification script

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TEST_LOG="docker-test-${TIMESTAMP// /-}.log"

log_test() {
    local status=$1
    local message=$2
    echo "[$TIMESTAMP] [$status] $message" | tee -a "$TEST_LOG"
}

echo "======================================"
echo "Docker System Monitoring - Test Suite"
echo "======================================"
echo "Log file: $TEST_LOG"
echo ""

# Test 1: Check Docker installation
echo "TEST 1: Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    log_test "PASS" "Docker installed: $DOCKER_VERSION"
else
    log_test "FAIL" "Docker not installed"
    exit 1
fi

echo ""

# Test 2: Check Docker daemon
echo "TEST 2: Checking Docker daemon..."
if docker info &> /dev/null; then
    log_test "PASS" "Docker daemon is running"
else
    log_test "FAIL" "Docker daemon is not running"
    exit 1
fi

echo ""

# Test 3: Check images exist
echo "TEST 3: Checking if images exist..."
if docker image ls | grep -q "system-monitor-bash"; then
    log_test "PASS" "system-monitor-bash image found"
else
    log_test "WARN" "system-monitor-bash image not found - building..."
    docker build -f Dockerfile.bash -t system-monitor-bash:latest . >> "$TEST_LOG" 2>&1
fi

if docker image ls | grep -q "system-monitor-python"; then
    log_test "PASS" "system-monitor-python image found"
else
    log_test "WARN" "system-monitor-python image not found - building..."
    docker build -f Dockerfile.python -t system-monitor-python:latest . >> "$TEST_LOG" 2>&1
fi

echo ""

# Test 4: Check volumes
echo "TEST 4: Checking Docker volumes..."
if docker volume ls | grep -q "monitoring-logs-bash"; then
    log_test "PASS" "monitoring-logs-bash volume exists"
else
    log_test "WARN" "Creating monitoring-logs-bash volume..."
    docker volume create monitoring-logs-bash
    log_test "PASS" "monitoring-logs-bash volume created"
fi

if docker volume ls | grep -q "monitoring-logs-python"; then
    log_test "PASS" "monitoring-logs-python volume exists"
else
    log_test "WARN" "Creating monitoring-logs-python volume..."
    docker volume create monitoring-logs-python
    log_test "PASS" "monitoring-logs-python volume created"
fi

echo ""

# Test 5: Stop existing containers
echo "TEST 5: Checking for existing containers..."
if docker ps -a | grep -q "monitor-bash"; then
    log_test "INFO" "Stopping existing monitor-bash container..."
    docker stop monitor-bash 2>/dev/null
    docker rm monitor-bash 2>/dev/null
fi

if docker ps -a | grep -q "monitor-python"; then
    log_test "INFO" "Stopping existing monitor-python container..."
    docker stop monitor-python 2>/dev/null
    docker rm monitor-python 2>/dev/null
fi

echo ""

# Test 6: Run containers
echo "TEST 6: Starting containers..."
docker run -d \
    -v monitoring-logs-bash:/var/log \
    --name monitor-bash \
    --restart unless-stopped \
    system-monitor-bash:latest >> "$TEST_LOG" 2>&1

if [ $? -eq 0 ]; then
    log_test "PASS" "Bash container started successfully"
    sleep 2
else
    log_test "FAIL" "Failed to start Bash container"
fi

docker run -d \
    -v monitoring-logs-python:/var/log \
    --name monitor-python \
    --restart unless-stopped \
    system-monitor-python:latest >> "$TEST_LOG" 2>&1

if [ $? -eq 0 ]; then
    log_test "PASS" "Python container started successfully"
    sleep 2
else
    log_test "FAIL" "Failed to start Python container"
fi

echo ""

# Test 7: Container health check
echo "TEST 7: Checking container status..."
if docker ps | grep -q "monitor-bash"; then
    log_test "PASS" "Bash container is running"
else
    log_test "FAIL" "Bash container is not running"
fi

if docker ps | grep -q "monitor-python"; then
    log_test "PASS" "Python container is running"
else
    log_test "FAIL" "Python container is not running"
fi

echo ""

# Test 8: Wait and collect logs
echo "TEST 8: Collecting logs (waiting 15 seconds)..."
sleep 15

echo ""

# Test 9: Check container logs exist
echo "TEST 9: Verifying logs..."
BASH_LOGS=$(docker logs monitor-bash 2>/dev/null | wc -l)
if [ "$BASH_LOGS" -gt 0 ]; then
    log_test "PASS" "Bash container logs exist ($BASH_LOGS lines)"
else
    log_test "WARN" "Bash container has no logs yet"
fi

PYTHON_LOGS=$(docker logs monitor-python 2>/dev/null | wc -l)
if [ "$PYTHON_LOGS" -gt 0 ]; then
    log_test "PASS" "Python container logs exist ($PYTHON_LOGS lines)"
else
    log_test "WARN" "Python container has no logs yet"
fi

echo ""

# Test 10: Check log files in volumes
echo "TEST 10: Verifying log files in volumes..."
BASH_FILE_SIZE=$(docker run --rm -v monitoring-logs-bash:/var/log alpine du -b /var/log/system-monitor.log 2>/dev/null | awk '{print $1}')
if [ -n "$BASH_FILE_SIZE" ] && [ "$BASH_FILE_SIZE" -gt 0 ]; then
    log_test "PASS" "Bash log file exists (${BASH_FILE_SIZE} bytes)"
else
    log_test "WARN" "Bash log file not found or empty"
fi

PYTHON_FILE_SIZE=$(docker run --rm -v monitoring-logs-python:/var/log alpine du -b /var/log/system-monitor.log 2>/dev/null | awk '{print $1}')
if [ -n "$PYTHON_FILE_SIZE" ] && [ "$PYTHON_FILE_SIZE" -gt 0 ]; then
    log_test "PASS" "Python log file exists (${PYTHON_FILE_SIZE} bytes)"
else
    log_test "WARN" "Python log file not found or empty"
fi

echo ""

# Test 11: Verify log content
echo "TEST 11: Verifying log content..."
BASH_CONTENT=$(docker run --rm -v monitoring-logs-bash:/var/log alpine grep -c "INFO" /var/log/system-monitor.log 2>/dev/null)
if [ -n "$BASH_CONTENT" ] && [ "$BASH_CONTENT" -gt 0 ]; then
    log_test "PASS" "Bash log contains INFO entries ($BASH_CONTENT)"
else
    log_test "WARN" "Bash log has no INFO entries"
fi

PYTHON_CONTENT=$(docker run --rm -v monitoring-logs-python:/var/log alpine grep -c "INFO" /var/log/system-monitor.log 2>/dev/null)
if [ -n "$PYTHON_CONTENT" ] && [ "$PYTHON_CONTENT" -gt 0 ]; then
    log_test "PASS" "Python log contains INFO entries ($PYTHON_CONTENT)"
else
    log_test "WARN" "Python log has no INFO entries"
fi

echo ""

# Test 12: Display sample logs
echo "TEST 12: Sample logs from containers..."
echo ""
echo "--- BASH Container (last 10 lines) ---"
docker logs monitor-bash 2>/dev/null | tail -10 | tee -a "$TEST_LOG"
echo ""
echo "--- PYTHON Container (last 10 lines) ---"
docker logs monitor-python 2>/dev/null | tail -10 | tee -a "$TEST_LOG"

echo ""
echo "======================================"
echo "Test Suite Complete"
echo "======================================"
echo ""
echo "Results saved to: $TEST_LOG"
echo ""
echo "Summary:"
echo "  Bash Container: $(docker ps | grep monitor-bash | wc -l) running"
echo "  Python Container: $(docker ps | grep monitor-python | wc -l) running"
echo "  Volumes: $(docker volume ls | grep monitoring-logs | wc -l) total"
echo ""
echo "Next steps:"
echo "  - Monitor logs: docker logs -f monitor-bash"
echo "  - Monitor logs: docker logs -f monitor-python"
echo "  - Stop containers: docker stop monitor-bash monitor-python"
echo "  - View full logs: docker run --rm -v monitoring-logs-bash:/var/log alpine tail -100 /var/log/system-monitor.log"
