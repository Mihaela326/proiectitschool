# Docker Implementation - Visual Guide & Workflows

## 🎯 Getting Started (Choose Your Path)

### Path 1: Docker Compose (Easiest - Recommended)
```
START
  ↓
docker-compose up -d
  ↓
docker-compose logs -f
  ↓
View monitoring output
  ↓
DONE ✅
```

### Path 2: PowerShell (Windows Users)
```
START
  ↓
.\build.ps1
  ↓
.\run.ps1
  ↓
.\verify-logs.ps1
  ↓
View logs in PowerShell
  ↓
DONE ✅
```

### Path 3: Bash (Linux/WSL2 Users)
```
START
  ↓
chmod +x *.sh
  ↓
./build.sh
  ↓
./run.sh
  ↓
./verify-logs.sh
  ↓
View logs in terminal
  ↓
DONE ✅
```

---

## 📊 Container Lifecycle

```
┌─────────────────────────────────────────────────────┐
│         CONTAINER LIFECYCLE DIAGRAM                 │
└─────────────────────────────────────────────────────┘

Step 1: BUILD PHASE
┌──────────────────────────────┐
│ docker build ...             │
│ ├── Pull base image          │
│ ├── Install dependencies     │
│ ├── Copy scripts & config    │
│ ├── Set permissions          │
│ └── Create image            │
└──────────────────────────────┘

Step 2: RUN PHASE
┌──────────────────────────────┐
│ docker run ...               │
│ ├── Create container         │
│ ├── Mount volumes            │
│ ├── Set environment          │
│ ├── Start process            │
│ └── Begin monitoring         │
└──────────────────────────────┘

Step 3: OPERATION PHASE
┌──────────────────────────────┐
│ Continuous Monitoring        │
│ ├── Collect system info      │
│ ├── Print to stdout          │
│ ├── Write to log file        │
│ ├── Update every 5 seconds   │
│ └── Persist in volumes       │
└──────────────────────────────┘

Step 4: LOGS PHASE
┌──────────────────────────────┐
│ Log Persistence              │
│ ├── Write to volume          │
│ ├── Maintain log format      │
│ ├── Accumulate over time     │
│ ├── Survive restarts         │
│ └── Available for analysis   │
└──────────────────────────────┘
```

---

## 🔄 Data Flow Diagram

```
Container: Bash Monitoring
┌─────────────────────────────────────┐
│  System Call (every 5 sec)          │
│  ├── date, uname, free, df, top    │
│  └── /proc/loadavg                 │
│           ↓                          │
│  info.sh Script Processing          │
│  ├── Parse output                   │
│  ├── Format data                    │
│  └── Determine level                │
│           ↓                          │
│  ┌─────────────────────┐            │
│  │ STDOUT (Console)    │ ← docker logs
│  └─────────────────────┘            │
│           ↑                          │
│  ┌─────────────────────┐            │
│  │ FILE LOG            │ ← volumes  │
│  │ /var/log/           │            │
│  │ system-monitor.log  │            │
│  └─────────────────────┘            │
└─────────────────────────────────────┘
```

---

## 📈 Update Cycle Diagram

```
Timeline (every 5 seconds):

Second 0
├─ Collect system metrics
├─ Format data
├─ Log to stdout
└─ Write to file

Second 1
├─ No action

Second 2
├─ No action

Second 3
├─ No action

Second 4
├─ No action

Second 5
├─ Collect system metrics (repeat)
├─ Format data
├─ Log to stdout
└─ Write to file

[Pattern repeats...]
```

---

## 🗂️ Volume Structure

```
Docker Host Machine
│
├─ monitoring-logs-bash (Volume)
│  └─ /var/log/
│     └─ system-monitor.log  ← Bash container writes here
│
└─ monitoring-logs-python (Volume)
   └─ /var/log/
      └─ system-monitor.log  ← Python container writes here
```

---

## 🔍 Log Verification Workflow

```
┌─────────────────────────────────┐
│  Want to verify logs?           │
└─────────────────────────────────┘
         ↓
    ┌────────────────────────────────┐
    │ Real-time (stdout)?            │
    └────────────────────────────────┘
         ↙              ↘
    YES             NO
     │                │
     ↓                ↓
docker logs -f    docker run --rm \
monitor-bash      -v volume:/var/log \
                  alpine tail -100 \
                  /var/log/...
```

---

## 🎬 Complete Workflow Example

```
USER INPUT:
$ docker-compose up -d
  │
  ├─→ Build bash image
  │    └─→ Download Ubuntu 22.04
  │    └─→ Install dependencies
  │    └─→ Copy info.sh
  │    └─→ Image created ✓
  │
  ├─→ Build python image
  │    └─→ Download Python 3.11
  │    └─→ Install dependencies
  │    └─→ Copy info.py
  │    └─→ Image created ✓
  │
  ├─→ Create monitoring-logs-bash volume
  │    └─→ Volume ready ✓
  │
  ├─→ Create monitoring-logs-python volume
  │    └─→ Volume ready ✓
  │
  ├─→ Start monitor-bash container
  │    └─→ Container running ✓
  │
  ├─→ Start monitor-python container
  │    └─→ Container running ✓
  │
  └─→ Both containers now monitor systems

VIEWING LOGS:
$ docker logs -f monitor-bash
  │
  └─→ Shows live output from container
      [Real-time system information stream...]

VIEWING PERSISTED LOGS:
$ docker run --rm -v monitoring-logs-bash:/var/log \
    alpine tail /var/log/system-monitor.log
  │
  └─→ Shows accumulated log entries
      [Timestamped log entries...]
```

---

## 🛠️ Container Interaction Patterns

```
PATTERN 1: View Live Monitoring
┌──────────────────┐
│ docker logs -f   │
└──────────────────┘
        ↓
   [Real-time output]
   [System info every 5s]
   [Press Ctrl+C to exit]

PATTERN 2: Check Log Files
┌──────────────────────────────────┐
│ docker run --rm -v volume:/path   │
│ alpine cat /path/file             │
└──────────────────────────────────┘
        ↓
   [File contents displayed]
   [Complete log history]

PATTERN 3: Analyze Specific Data
┌──────────────────────────────────┐
│ docker run --rm -v volume:/path   │
│ alpine grep "CRITICAL" /path/file │
└──────────────────────────────────┘
        ↓
   [Filtered log entries]
   [Only CRITICAL alerts]

PATTERN 4: Monitor Container Status
┌──────────────────────────────────┐
│ docker ps --filter "name=monitor" │
└──────────────────────────────────┘
        ↓
   [Container list]
   [Status information]
```

---

## 📝 Log Entry Generation Flow

```
info.sh / info.py executes
     ↓
Collect system data (date, cpu, memory, disk, etc)
     ↓
Format data with colors and structure
     ↓
┌─────────────────────────┐
│ print(formatted_output) │ ← Goes to STDOUT
└─────────────────────────┘
     ↓ AND ↓
┌─────────────────────────────────────────┐
│ logger.info(message)                    │
│ └─→ "[TIMESTAMP] INFO: message"         │
│ └─→ Appended to /var/log/...            │
└─────────────────────────────────────────┘
     ↓
Captured by Docker as container logs
     ↓
docker logs command can retrieve it
     ↓
Available for analysis and monitoring
```

---

## 🔧 Customization Decision Tree

```
Want to change monitoring interval?
  ↓
YES → Edit docker-compose.yml
      Change: command: ["/app/info.sh", "5"]
      To:     command: ["/app/info.sh", "10"]
      ↓
      Rebuild: docker-compose down && docker-compose up -d

Want to change log path?
  ↓
YES → Edit .env file
      Change: log_path=/var/log/system-monitor.log
      To:     log_path=/var/custom/logs/monitor.log
      ↓
      Rebuild: docker build -f Dockerfile.bash -t system-monitor-bash:latest .

Want to use host volume instead?
  ↓
YES → Edit docker-compose.yml
      Change: monitoring-logs-bash: (named volume)
      To:     /host/path:/var/log (bind mount)
      ↓
      Restart: docker-compose down && docker-compose up -d
```

---

## 📊 File Sizes & Performance

```
BUILD PHASE
├─ system-monitor-bash image:      77 MB
├─ system-monitor-python image:   138 MB
└─ Total disk for images:         215 MB

RUNTIME (per container)
├─ Memory usage:            50-100 MB
├─ CPU usage:               < 0.5%
└─ Disk I/O:                Minimal

LOG FILES (per hour)
├─ Bash logs:               1-2 MB
├─ Python logs:             1-2 MB
└─ Total log growth:        2-4 MB/hour
```

---

## ✅ Verification Checklist Workflow

```
START CONTAINERS
    ↓
Wait 2 seconds
    ↓
Check running:  docker ps --filter "name=monitor-"
    ├─ monitor-bash present? ✓
    ├─ monitor-python present? ✓
    └─ Both Up? ✓
    ↓
View logs:      docker logs monitor-bash
    ├─ System info visible? ✓
    ├─ Timestamps present? ✓
    └─ Data collected? ✓
    ↓
Wait 15 seconds (3 cycles)
    ↓
Check volumes:  docker run --rm -v volume:/var/log alpine ls -la /var/log/
    ├─ system-monitor.log exists? ✓
    ├─ File size > 0? ✓
    └─ Multiple entries? ✓
    ↓
View file:      docker run --rm -v volume:/var/log alpine tail /var/log/...
    ├─ Log entries present? ✓
    ├─ Timestamps increasing? ✓
    ├─ INFO levels present? ✓
    └─ Format correct? ✓
    ↓
ALL TESTS PASSED ✓
```

---

## 🎯 Troubleshooting Decision Tree

```
Containers won't start?
  ├─→ Run: docker logs monitor-bash
  ├─→ Read error message
  ├─→ Check: docker images | grep system-monitor
  └─→ Rebuild if needed: ./build.sh

No logs appearing?
  ├─→ Check: docker ps --filter "name=monitor-"
  ├─→ Wait 5 seconds (logs update every 5s)
  ├─→ Run: docker logs monitor-bash
  └─→ Check volume mounted: docker inspect monitor-bash

Permission denied errors?
  ├─→ Fix: chmod 755 *.sh
  ├─→ Fix: chmod 644 .env
  └─→ Retry build/run

Out of disk space?
  ├─→ Clean: docker system prune -a --volumes
  ├─→ Or remove specific: docker volume rm monitoring-logs-bash
  └─→ Restart containers

Still having issues?
  ├─→ Check Docker running: docker ps
  ├─→ Check Docker daemon: docker info
  └─→ Restart Docker service
```

---

## 🚀 Deployment Scenario Examples

### Scenario 1: Development Environment
```
docker-compose up -d
docker logs -f monitor-bash &
docker logs -f monitor-python
→ Monitor both in real-time during development
```

### Scenario 2: Production Monitoring
```
docker-compose up -d
→ Containers run continuously
→ Logs accumulate in volumes
→ Review logs periodically
→ Archive old logs as needed
```

### Scenario 3: Testing & Validation
```
./test.sh
→ Runs complete test suite
→ Verifies both containers
→ Checks logs are being created
→ Generates test report
```

### Scenario 4: CI/CD Pipeline
```
docker build -f Dockerfile.bash -t system-monitor-bash:v1 .
docker build -f Dockerfile.python -t system-monitor-python:v1 .
docker run -d ... system-monitor-bash:v1
docker run -d ... system-monitor-python:v1
→ Automated deployment
→ Version-tagged images
```

---

## 📱 Quick Reference Cards

### Card 1: Essential Commands
```
START:
  docker-compose up -d

MONITOR:
  docker logs -f monitor-bash

VERIFY:
  docker ps --filter "name=monitor-"

STOP:
  docker-compose down

LOGS:
  docker run --rm -v monitoring-logs-bash:/var/log \
    alpine tail /var/log/system-monitor.log
```

### Card 2: Troubleshooting
```
Error?
  docker logs monitor-bash

Not running?
  docker build -f Dockerfile.bash -t system-monitor-bash .

Volumes?
  docker volume ls
  docker volume inspect monitoring-logs-bash

Cleanup:
  docker system prune -a --volumes
```

### Card 3: Log Analysis
```
All INFO entries:
  grep INFO /var/log/system-monitor.log

All CRITICAL entries:
  grep CRITICAL /var/log/system-monitor.log

Last 100 lines:
  tail -100 /var/log/system-monitor.log

Last hour (approx):
  tail -1000 /var/log/system-monitor.log
```

---

**Last Updated:** November 30, 2025  
**Status:** Complete and Ready ✅
