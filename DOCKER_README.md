# System Monitoring Docker Containers

This project contains two Docker containers that run system monitoring scripts (Bash and Python), collecting and logging system information every X seconds.

## Project Structure

```
.
├── info.sh                    # Bash monitoring script
├── info.py                    # Python monitoring script
├── .env                       # Environment variables (log_path)
├── requirements.txt           # Python dependencies
├── Dockerfile.bash            # Docker image for Bash script
├── Dockerfile.python          # Docker image for Python script
├── docker-compose.yml         # Docker Compose configuration
├── build.sh                   # Build both images
├── run.sh                     # Launch both containers
└── verify-logs.sh             # Verify container logs
```

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (optional, for easier orchestration)
- Linux/WSL2 environment for running bash scripts

## Quick Start

### Option 1: Using Docker Compose (Recommended)

```bash
# Build and run both containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

### Option 2: Manual Build and Run

```bash
# Make scripts executable
chmod +x build.sh run.sh verify-logs.sh

# Build both images
./build.sh

# Launch both containers
./run.sh

# Verify logs
./verify-logs.sh
```

### Option 3: Individual Commands

```bash
# Build Bash image
docker build -f Dockerfile.bash -t system-monitor-bash:latest .

# Build Python image
docker build -f Dockerfile.python -t system-monitor-python:latest .

# Create volumes
docker volume create monitoring-logs-bash
docker volume create monitoring-logs-python

# Run Bash container
docker run -d \
  -v monitoring-logs-bash:/var/log \
  --name monitor-bash \
  system-monitor-bash:latest

# Run Python container
docker run -d \
  -v monitoring-logs-python:/var/log \
  --name monitor-python \
  system-monitor-python:latest
```

## Monitoring Containers

### View Running Containers

```bash
docker ps --filter "name=monitor-"
```

### View Container Logs

**Bash container (stdout):**
```bash
docker logs -f monitor-bash
```

**Python container (stdout):**
```bash
docker logs -f monitor-python
```

### View Log Files in Volumes

**Bash container logs:**
```bash
docker run --rm -v monitoring-logs-bash:/var/log alpine cat /var/log/system-monitor.log
```

**Python container logs:**
```bash
docker run --rm -v monitoring-logs-python:/var/log alpine cat /var/log/system-monitor.log
```

### Tail Last Lines

```bash
# Bash logs (last 50 lines)
docker run --rm -v monitoring-logs-bash:/var/log alpine tail -50 /var/log/system-monitor.log

# Python logs (last 50 lines)
docker run --rm -v monitoring-logs-python:/var/log alpine tail -50 /var/log/system-monitor.log
```

## Container Configuration

### Environment Variables

Both containers use:
- `LOG_PATH`: Path to log file (default: `/var/log/system-monitor.log`)
- `PYTHONUNBUFFERED=1` (Python only): Ensures real-time output

### Volumes

- `monitoring-logs-bash`: Stores logs from Bash container
- `monitoring-logs-python`: Stores logs from Python container

### Restart Policy

Both containers are configured with `restart: unless-stopped` for automatic recovery.

## Log Format

Both scripts log with the following format:
```
[YYYY-MM-DD HH:MM:SS] LEVEL   : message
```

### Log Levels

- **INFO**: Normal operations (metrics collection)
- **WARN**: Warnings or data collection issues
- **CRITICAL**: Alert conditions (RAM < 15%, Disk > 90%)

## System Information Collected

- **Date & Time**: Current timestamp
- **Linux Distribution**: OS name, version, kernel version, hostname
- **Load Average**: System load (1, 5, 15 minutes)
- **Uptime**: System running time
- **CPU Usage**: CPU utilization percentage
- **Memory Usage**: Total, used, available RAM and percentage
- **Disk Usage**: Disk space per partition
- **Alerts**: Critical alerts for low RAM and high disk usage

## Stopping Containers

```bash
# Stop individual containers
docker stop monitor-bash
docker stop monitor-python

# Or with docker-compose
docker-compose down
```

## Removing Containers and Volumes

```bash
# Remove containers
docker rm monitor-bash monitor-python

# Remove volumes (WARNING: deletes logs)
docker volume rm monitoring-logs-bash monitoring-logs-python

# Or with docker-compose
docker-compose down -v
```

## Customization

### Change Log Path

Edit `.env` file:
```env
log_path=/custom/path/to/logs
```

### Change Monitoring Interval

Modify the CMD in Dockerfiles:
```dockerfile
CMD ["/app/info.sh", "10"]     # 10 seconds for Bash
CMD ["python3", "/app/info.py", "10"]  # 10 seconds for Python
```

### Add Custom Log Volume Mounts

Modify docker-compose.yml or docker run commands:
```bash
docker run -d \
  -v /host/path:/var/log \
  --name monitor-bash \
  system-monitor-bash:latest
```

## Troubleshooting

### Container exits immediately
Check logs: `docker logs monitor-bash`

### Permission denied errors
Ensure `.env` and scripts have proper permissions:
```bash
chmod 644 .env
chmod 755 *.sh
```

### Logs not appearing
Verify log volume is mounted:
```bash
docker inspect monitor-bash | grep -A 20 Mounts
```

### Python modules not found
Rebuild images to install dependencies:
```bash
docker build --no-cache -f Dockerfile.python -t system-monitor-python:latest .
```

## Docker Image Sizes

- **Bash**: ~77 MB (based on Ubuntu 22.04)
- **Python**: ~138 MB (based on Python 3.11-slim)

## Performance Notes

- Monitoring interval: 5 seconds (default, configurable)
- CPU usage: Low (< 1% per container)
- Memory usage: Minimal (depends on system complexity)
- Logs grow approximately 1-2 KB per interval

## Security Considerations

- Containers run with default restrictions
- Volumes are isolated per container
- Logs may contain sensitive system information
- Consider using secrets management for production environments

## License

This project is provided as-is for educational purposes.
