# PowerShell run script for both Docker containers

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Launching Docker Containers" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Create volumes if they don't exist
Write-Host "Creating Docker volumes..." -ForegroundColor Yellow
docker volume create monitoring-logs-bash 2>$null
docker volume create monitoring-logs-python 2>$null

Write-Host ""

# Run Bash-based container
Write-Host "Checking for required Docker images..." -ForegroundColor Yellow
$bashImage = docker images -q system-monitor-bash:latest 2>$null
if (-not $bashImage) {
    Write-Host "Bash image not found locally. Building system-monitor-bash..." -ForegroundColor Yellow
    docker build -f Dockerfile.bash -t system-monitor-bash:latest .
}
$pyImage = docker images -q system-monitor-python:latest 2>$null
if (-not $pyImage) {
    Write-Host "Python image not found locally. Building system-monitor-python..." -ForegroundColor Yellow
    docker build -f Dockerfile.python -t system-monitor-python:latest .
}
$hubImage = docker images -q system-monitor-hub:latest 2>$null
if (-not $hubImage) {
    Write-Host "Hub image not found locally. Building system-monitor-hub..." -ForegroundColor Yellow
    docker build -f Dockerfile.hub -t system-monitor-hub:latest .
}

Write-Host "[1/2] Starting Bash monitoring container..." -ForegroundColor Yellow
# Remove existing container with same name if present
$existingBash = docker ps -a --filter "name=monitor-bash" --format "{{.ID}}"
if ($existingBash) {
    Write-Host "Existing container 'monitor-bash' found. Removing..." -ForegroundColor Yellow
    docker rm -f monitor-bash 2>$null
}
docker run -d `
    -v monitoring-logs-bash:/var/log `
    --name monitor-bash `
    --restart unless-stopped `
    system-monitor-bash:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Bash container started (ID: monitor-bash)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Failed to start Bash container" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Run Python-based container
Write-Host "[2/2] Starting Python monitoring container..." -ForegroundColor Yellow
# Remove existing container with same name if present
$existingPython = docker ps -a --filter "name=monitor-python" --format "{{.ID}}"
if ($existingPython) {
    Write-Host "Existing container 'monitor-python' found. Removing..." -ForegroundColor Yellow
    docker rm -f monitor-python 2>$null
}
docker run -d `
    -v monitoring-logs-python:/var/log `
    --name monitor-python `
    --restart unless-stopped `
    system-monitor-python:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Python container started (ID: monitor-python)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Failed to start Python container" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Run Monitoring Hub container
Write-Host "[3/3] Starting Monitoring Hub container..." -ForegroundColor Yellow
# Remove existing container with same name if present
$existingHub = docker ps -a --filter "name=monitor-hub" --format "{{.ID}}"
if ($existingHub) {
    Write-Host "Existing container 'monitor-hub' found. Removing..." -ForegroundColor Yellow
    docker rm -f monitor-hub 2>$null
}
docker run -d `
    -p 8080:8080 `
    -v monitoring-logs-bash:/var/log/bash:ro `
    -v monitoring-logs-python:/var/log/python:ro `
    --name monitor-hub `
    --restart unless-stopped `
    system-monitor-hub:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Monitoring Hub started (ID: monitor-hub)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Failed to start Monitoring Hub" -ForegroundColor Red
    exit 1
}
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Containers launched successfully!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Running containers:" -ForegroundColor Green
docker ps --filter "name=monitor-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
Write-Host ""
Write-Host "View logs:" -ForegroundColor Yellow
Write-Host "  Bash:   docker logs -f monitor-bash"
Write-Host "  Python: docker logs -f monitor-python"
Write-Host ""
Write-Host "Stop containers:" -ForegroundColor Yellow
Write-Host "  Bash:   docker stop monitor-bash"
Write-Host "  Python: docker stop monitor-python"
Write-Host ""
Write-Host "Remove containers:" -ForegroundColor Yellow
Write-Host "  docker rm monitor-bash monitor-python"
