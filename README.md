# Complete Docker Implementation - Quick Start Guide

## 📋 Project Overview

This project implements **two complete Docker containers** that monitor Linux system information:
1. **Bash-based container** (Ubuntu 22.04)
2. **Python-based container** (Python 3.11-slim)

Both containers collect and log system metrics every 5 seconds.

---

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Docker Desktop installed and running
- At least 500MB free disk space

### Option 1: Using Docker Compose (Easiest)
```bash
cd d:\proiectitschool
docker-compose up -d
docker-compose logs -f
```

### Option 2: PowerShell (Windows)
```powershell
cd d:\proiectitschool
.\build.ps1
.\run.ps1
.\verify-logs.ps1
```

### Option 3: Bash (Linux/WSL2)
```bash
cd d:\proiectitschool
chmod +x build.sh run.sh verify-logs.sh test.sh
./build.sh
./run.sh
./verify-logs.sh
```

---

## 📁 Project Structure

```
d:\proiectitschool\
├── Monitoring Scripts
│   ├── info.sh                  # Bash monitoring script
│   └── info.py                  # Python monitoring script
├── Docker Configuration
│   ├── Dockerfile.bash          # Ubuntu + Bash setup
│   ├── Dockerfile.python        # Python 3.11-slim setup
│   ├── docker-compose.yml       # Docker Compose orchestration
│   ├── .env                     # Environment variables
│   └── requirements.txt         # Python dependencies
├── Build & Run (Bash)
│   ├── build.sh                 # Build images
│   ├── run.sh                   # Start containers
│   ├── verify-logs.sh           # Check logs
│   └── test.sh                  # Full test suite
├── Build & Run (PowerShell)
│   ├── build.ps1                # Build images
│   ├── run.ps1                  # Start containers
│   └── verify-logs.ps1          # Check logs
└── Documentation
    ├── README.md                # This file
    ├── DOCKER_README.md         # Detailed Docker guide
    └── DOCKER_SETUP.md          # Architecture & setup details
```

---

## ✅ Step-by-Step Instructions

### Step 1: Build Images
**PowerShell:**
```powershell
.\build.ps1
```

**Bash:**
```bash
./build.sh
```

**Output:**
```
✓ Bash image built successfully
✓ Python image built successfully
```

### Step 2: Start Containers
**PowerShell:**
```powershell
.\run.ps1
```

**Bash:**
```bash
./run.sh
```

**Output:**
```
✓ Bash container started (ID: monitor-bash)
✓ Python container started (ID: monitor-python)

Running containers:
NAMES              IMAGE                       STATUS
monitor-bash       system-monitor-bash:latest  Up 2 seconds
monitor-python     system-monitor-python:latest Up 1 second
```

### Step 3: View Logs
**PowerShell:**
```powershell
.\verify-logs.ps1
```

**Bash:**
```bash
./verify-logs.sh
```

**Live monitoring:**
```bash
docker logs -f monitor-bash
docker logs -f monitor-python
```

### Step 4: Wait for Logs to Accumulate
Logs appear immediately and grow continuously. After 1-2 minutes, you should see:
- Date and time entries
- System information (OS, kernel, hostname)
- Load average, uptime, CPU, memory usage
- Disk usage information
- Alert entries (if thresholds are exceeded)

---

## 📊 Expected Output

### Container Output (stdout)
```
======================================
     System Information Monitor
======================================

Date and Time: 2025-11-30 14:35:22

Linux Distribution:
  OS: Ubuntu 22.04.1 LTS
  ID: ubuntu
Kernel: 5.15.0-84-generic
Hostname: container-id-xyz

Load Average: 0.15, 0.12, 0.08

Uptime: up 2 days, 3 hours, 45 minutes

CPU Usage: 5.2%

Memory Usage:
  Total: 7.7GB
  Used: 2.3GB
  Available: 4.8GB
  Percentage: 29.9%

Disk Usage:
  /dev/sda1            2.1G / 50G (4%)

========== ALERTS ==========
No critical alerts
===========================
```

### Log File Output
```
[2025-11-30 14:35:22] INFO    : Date and Time: 2025-11-30 14:35:22
[2025-11-30 14:35:22] INFO    : OS: Ubuntu 22.04.1 LTS (ID: ubuntu)
[2025-11-30 14:35:22] INFO    : Kernel: 5.15.0-84-generic
[2025-11-30 14:35:22] INFO    : Load Average: 0.15, 0.12, 0.08
[2025-11-30 14:35:22] INFO    : Memory Usage: Total=7.7GB, Used=2.3GB, Available=4.8GB, Percentage=29.9%
[2025-11-30 14:35:22] INFO    : No critical alerts
```

---

## 🔍 Verification Checklist

After running the containers, verify:

```
✓ Both containers running:
  docker ps --filter "name=monitor-"

✓ Bash container has logs:
  docker logs monitor-bash | head -20

✓ Python container has logs:
  docker logs monitor-python | head -20

✓ Log files exist in volumes:
  docker run --rm -v monitoring-logs-bash:/var/log alpine ls -la /var/log/

✓ Log entries contain INFO level:
  docker run --rm -v monitoring-logs-bash:/var/log alpine grep INFO /var/log/system-monitor.log | head -5

✓ New entries appear every 5 seconds
```

---

## 🎯 Common Commands

### View Logs
```bash
# Real-time Bash container logs
docker logs -f monitor-bash

# Real-time Python container logs
docker logs -f monitor-python

# Last 50 lines of Bash log file
docker run --rm -v monitoring-logs-bash:/var/log alpine tail -50 /var/log/system-monitor.log

# Last 50 lines of Python log file
docker run --rm -v monitoring-logs-python:/var/log alpine tail -50 /var/log/system-monitor.log
```

### Container Management
```bash
# List running containers
docker ps --filter "name=monitor-"

# Stop containers
docker stop monitor-bash monitor-python

# Restart containers
docker restart monitor-bash monitor-python

# Remove containers
docker rm monitor-bash monitor-python

# Remove volumes (⚠️ deletes logs)
docker volume rm monitoring-logs-bash monitoring-logs-python
```

### Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose stop

# Remove services and volumes
docker-compose down -v
```

---

## 📝 What Gets Logged

### Collected Information
- ✅ **Date & Time** - Current timestamp
- ✅ **OS Info** - Distribution, version, kernel, hostname
- ✅ **Load Average** - 1, 5, 15-minute averages
- ✅ **Uptime** - System running time
- ✅ **CPU Usage** - CPU utilization percentage
- ✅ **Memory** - Total, used, available, percentage
- ✅ **Disk Space** - Usage per partition
- ✅ **Alerts** - Critical conditions (RAM < 15%, Disk > 90%)

### Log Levels
- **INFO** - Normal operations
- **WARN** - Warnings or data collection issues
- **CRITICAL** - Alert conditions

### Update Frequency
Default: **Every 5 seconds** (configurable)

---

## 🔧 Customization

### Change Log Path
Edit `.env`:
```env
log_path=/custom/path/to/logs
```

### Change Monitoring Interval
Edit docker-compose.yml:
```yaml
command: ["/app/info.sh", "10"]  # 10 seconds
```

### Mount External Volume
```bash
docker run -d \
  -v /host/logs:/var/log \
  --name monitor-bash \
  system-monitor-bash:latest
```

---

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs for errors
docker logs monitor-bash
docker logs monitor-python

# Check image exists
docker image ls | grep system-monitor

# Rebuild if needed
docker build -f Dockerfile.bash -t system-monitor-bash:latest .
```

### No logs appearing
```bash
# Wait a few seconds (logs appear every 5 seconds)
sleep 5
docker logs monitor-bash

# Check volume is mounted
docker inspect monitor-bash | grep -A 20 Mounts
```

### Permission errors
```bash
# Fix file permissions
chmod 755 *.sh *.ps1
chmod 644 .env

# Or use Docker Compose (handles permissions automatically)
docker-compose up -d
```

### Out of disk space
```bash
# Clean up Docker
docker system prune -a --volumes

# Or remove old containers/volumes
docker rm monitor-bash monitor-python
docker volume rm monitoring-logs-bash monitoring-logs-python
```

---

## 📊 System Requirements

- **Disk Space**: 
  - ~77 MB for Bash image
  - ~138 MB for Python image
  - ~1-2 MB/hour for logs
- **Memory**: ~100 MB per container
- **CPU**: Minimal (< 1% per container)
- **Network**: Not required

---

## 🚀 Next Steps

1. **Monitor in Real-Time**
   ```bash
   docker logs -f monitor-bash &
   docker logs -f monitor-python
   ```

2. **Analyze Logs Over Time**
   ```bash
   docker run --rm -v monitoring-logs-bash:/var/log alpine cat /var/log/system-monitor.log | grep CRITICAL
   ```

3. **Set Up Log Rotation** (optional)
   ```bash
   # Implement logrotate or similar tool
   ```

4. **Export Logs to Cloud** (optional)
   ```bash
   # Mount volume to cloud storage or use backup solution
   ```

---

## 📞 Support

For detailed information, see:
- `DOCKER_README.md` - Comprehensive Docker guide
- `DOCKER_SETUP.md` - Architecture and advanced configuration

For issues:
1. Check Docker is running: `docker ps`
2. Review logs: `docker logs monitor-bash`
3. Verify volumes: `docker volume ls`
4. Rebuild images: `docker build --no-cache -f Dockerfile.bash -t system-monitor-bash:latest .`

---

## ✨ Key Features

✅ **Dual Implementation** - Bash and Python versions  
✅ **Docker Best Practices** - Minimal images, proper logging  
✅ **Persistent Logs** - Data stored in Docker volumes  
✅ **Auto-Restart** - Containers restart if they fail  
✅ **Cross-Platform** - Works on Windows, Linux, macOS  
✅ **Easy Management** - Docker Compose or individual scripts  
✅ **Comprehensive Logging** - INFO, WARN, CRITICAL levels  
✅ **Health Monitoring** - Real-time alerts for critical conditions  

---

**Created:** November 30, 2025  
**Status:** ✅ Ready for Production Use  
**Version:** 1.0
