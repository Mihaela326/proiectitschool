# Docker Setup Summary

Two complete Docker implementations have been created for the system monitoring scripts.

## 📦 Files Created

### Dockerfiles
- **Dockerfile.bash** - Ubuntu-based image running Bash monitoring script
- **Dockerfile.python** - Python 3.11-slim image running Python monitoring script

### Configuration
- **docker-compose.yml** - Docker Compose orchestration file

### Build & Run Scripts
**Bash versions:**
- `build.sh` - Build both Docker images
- `run.sh` - Launch both containers
- `verify-logs.sh` - Check container logs

**PowerShell versions (Windows):**
- `build.ps1` - Build both Docker images
- `run.ps1` - Launch both containers
- `verify-logs.ps1` - Check container logs

### Documentation
- **DOCKER_README.md** - Comprehensive Docker setup guide

## 🚀 Quick Start

### On Linux/WSL2:
```bash
chmod +x build.sh run.sh verify-logs.sh
./build.sh
./run.sh
./verify-logs.sh
```

### On Windows (PowerShell):
```powershell
.\build.ps1
.\run.ps1
.\verify-logs.ps1
```

### Using Docker Compose (any platform):
```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

## 📋 Container Details

### Bash Container (system-monitor-bash)
- **Base Image**: Ubuntu 22.04
- **Size**: ~77 MB
- **Script**: `info.sh`
- **Dependencies**: bash, coreutils, procps, sysstat, bc
- **Log Volume**: `monitoring-logs-bash`

### Python Container (system-monitor-python)
- **Base Image**: Python 3.11-slim
- **Size**: ~138 MB
- **Script**: `info.py`
- **Dependencies**: psutil, python-dotenv (from requirements.txt)
- **Log Volume**: `monitoring-logs-python`

## 📝 What Gets Logged

Both containers log to `/var/log/system-monitor.log` inside their containers (persisted via volumes):

**Collected Information:**
- ✅ Date and Time (INFO)
- ✅ Linux Distribution & Kernel Info (INFO)
- ✅ Load Average (INFO)
- ✅ Uptime (INFO)
- ✅ CPU Usage (INFO)
- ✅ Memory Usage (INFO)
- ✅ Disk Usage (INFO)
- ✅ Critical Alerts (CRITICAL)
  - RAM available < 15%
  - Disk usage > 90%

**Log Format:**
```
[2025-11-30 14:30:45] INFO    : Date and Time: 2025-11-30 14:30:45
[2025-11-30 14:30:45] INFO    : OS: Ubuntu 22.04.1 LTS (ID: ubuntu)
[2025-11-30 14:30:45] INFO    : Load Average: 0.12, 0.08, 0.05
```

## 🔍 Verifying Logs

### View Container Output (stdout):
```bash
docker logs -f monitor-bash
docker logs -f monitor-python
```

### View Persisted Log Files:
```bash
# Bash logs
docker run --rm -v monitoring-logs-bash:/var/log alpine tail -100 /var/log/system-monitor.log

# Python logs
docker run --rm -v monitoring-logs-python:/var/log alpine tail -100 /var/log/system-monitor.log
```

### Inside Host System:
Volumes are managed by Docker, but you can inspect them:
```bash
docker volume inspect monitoring-logs-bash
docker volume inspect monitoring-logs-python
```

## 🎯 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                       │
├──────────────────────┬──────────────────────────────────────┤
│   Bash Container     │      Python Container                │
├──────────────────────┼──────────────────────────────────────┤
│ Ubuntu 22.04         │ Python 3.11-slim                     │
│ ├── info.sh (bash)   │ ├── info.py (python3)                │
│ └── .env             │ ├── requirements.txt                  │
│                      │ └── .env                              │
├──────────────────────┼──────────────────────────────────────┤
│ Volume:              │ Volume:                              │
│ monitoring-logs-bash │ monitoring-logs-python               │
│ └── /var/log/        │ └── /var/log/                        │
│     system-monitor   │     system-monitor                   │
│     .log             │     .log                             │
└──────────────────────┴──────────────────────────────────────┘
```

## ⚙️ Configuration

### Environment Variables
Both containers support:
- `LOG_PATH`: Log file location (default: `/var/log/system-monitor.log`)
- `PYTHONUNBUFFERED=1`: Real-time Python output (Python only)

### Monitoring Interval
Default: 5 seconds (configurable via CMD in Dockerfile or command argument)

### Log Path
Read from `.env` file:
```env
log_path=/var/log/system-monitor.log
```

## 🛑 Container Management

### Stop Containers
```bash
docker stop monitor-bash monitor-python
```

### Remove Containers
```bash
docker rm monitor-bash monitor-python
```

### Remove Volumes (⚠️ Deletes Logs)
```bash
docker volume rm monitoring-logs-bash monitoring-logs-python
```

### View Running Containers
```bash
docker ps --filter "name=monitor-"
```

## 🔧 Customization

### Change Monitoring Interval
Edit Dockerfile CMD or use docker-compose:
```dockerfile
CMD ["/app/info.sh", "10"]  # 10 seconds
```

### Mount Custom Log Directory
```bash
docker run -v /host/logs:/var/log --name monitor-bash system-monitor-bash:latest
```

### Rebuild Without Cache
```bash
docker build --no-cache -f Dockerfile.bash -t system-monitor-bash:latest .
```

## 📊 Expected Output Example

### Container Logs (stdout):
```
======================================
     System Information Monitor
======================================

Date and Time: 2025-11-30 14:35:22
Linux Distribution:
  OS: Ubuntu 22.04.1 LTS
  ID: ubuntu
Kernel: 5.15.0-84-generic
Hostname: f3a2b1c9e8d7

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

Next update in 5 seconds (press Ctrl+C to exit)...
```

### Log File:
```
[2025-11-30 14:35:22] INFO    : Date and Time: 2025-11-30 14:35:22
[2025-11-30 14:35:22] INFO    : OS: Ubuntu 22.04.1 LTS (ID: ubuntu)
[2025-11-30 14:35:22] INFO    : Kernel: 5.15.0-84-generic
[2025-11-30 14:35:22] INFO    : Hostname: f3a2b1c9e8d7
[2025-11-30 14:35:22] INFO    : Load Average: 0.15, 0.12, 0.08
[2025-11-30 14:35:22] INFO    : Uptime: up 2 days, 3 hours, 45 minutes
[2025-11-30 14:35:22] INFO    : CPU Usage: 5.2%
[2025-11-30 14:35:22] INFO    : Memory Usage: Total=7.7GB, Used=2.3GB, Available=4.8GB, Percentage=29.9%
[2025-11-30 14:35:22] INFO    : Disk Usage: /dev/sda1 = 2.1G / 50G (4%)
[2025-11-30 14:35:22] INFO    : No critical alerts
```

## ✅ Verification Checklist

After running the containers, verify:

- [ ] Both containers are running: `docker ps --filter "name=monitor-"`
- [ ] Bash container logs show system info: `docker logs monitor-bash`
- [ ] Python container logs show system info: `docker logs monitor-python`
- [ ] Log files exist in volumes: `docker run --rm -v monitoring-logs-bash:/var/log alpine ls -la /var/log/`
- [ ] Log files contain INFO/CRITICAL entries
- [ ] New entries appear every 5 seconds in logs
- [ ] No errors in container logs
- [ ] Containers restart automatically after being stopped

## 🐛 Troubleshooting

**Container exits immediately:**
```bash
docker logs monitor-bash  # Check error messages
```

**Permission issues:**
```bash
chmod 755 *.sh *.ps1
chmod 644 .env
```

**Images not found:**
```bash
docker build -f Dockerfile.bash -t system-monitor-bash:latest .
docker build -f Dockerfile.python -t system-monitor-python:latest .
```

**Volumes not mounted:**
```bash
docker volume ls
docker volume inspect monitoring-logs-bash
```

---

**Created:** November 30, 2025
**Status:** ✅ Ready for deployment
