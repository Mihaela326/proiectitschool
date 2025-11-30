# PowerShell build script for both Docker images

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Building Docker Images" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Build Bash-based image
Write-Host "[1/2] Building Bash monitoring image..." -ForegroundColor Yellow
docker build -f Dockerfile.bash -t system-monitor-bash:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Bash image built successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to build Bash image" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Build Python-based image
Write-Host "[2/2] Building Python monitoring image..." -ForegroundColor Yellow
docker build -f Dockerfile.python -t system-monitor-python:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Python image built successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to build Python image" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Build completed successfully!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Images created:" -ForegroundColor Green
Write-Host "  - system-monitor-bash:latest"
Write-Host "  - system-monitor-python:latest"
Write-Host ""
Write-Host "To run containers:" -ForegroundColor Yellow
Write-Host "  Bash:   docker run -v monitoring-logs-bash:/var/log --name monitor-bash system-monitor-bash:latest"
Write-Host "  Python: docker run -v monitoring-logs-python:/var/log --name monitor-python system-monitor-python:latest"
