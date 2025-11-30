# PowerShell script to verify logs from both containers

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Verifying Container Logs" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if containers are running
Write-Host "Checking container status..." -ForegroundColor Yellow
$bash_running = docker ps --filter "name=monitor-bash" --format "{{.Names}}" 2>$null | Select-String "monitor-bash" | Measure-Object | Select-Object -ExpandProperty Count
$python_running = docker ps --filter "name=monitor-python" --format "{{.Names}}" 2>$null | Select-String "monitor-python" | Measure-Object | Select-Object -ExpandProperty Count

Write-Host ""
if ($bash_running -eq 1) {
    Write-Host "✓ Bash container is running" -ForegroundColor Green
} else {
    Write-Host "✗ Bash container is not running" -ForegroundColor Red
}

if ($python_running -eq 1) {
    Write-Host "✓ Python container is running" -ForegroundColor Green
} else {
    Write-Host "✗ Python container is not running" -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "BASH Container Logs (last 30 lines)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
$bash_logs = docker logs monitor-bash 2>$null
if ($bash_logs) {
    $bash_logs | Select-Object -Last 30
} else {
    Write-Host "No logs available" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "PYTHON Container Logs (last 30 lines)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
$python_logs = docker logs monitor-python 2>$null
if ($python_logs) {
    $python_logs | Select-Object -Last 30
} else {
    Write-Host "No logs available" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Log Files in Volumes" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bash container log volume:" -ForegroundColor Yellow
$bash_file_logs = docker run --rm -v monitoring-logs-bash:/var/log alpine cat /var/log/system-monitor.log 2>$null
if ($bash_file_logs) {
    $bash_file_logs | Select-Object -Last 20
} else {
    Write-Host "No log file found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Python container log volume:" -ForegroundColor Yellow
$python_file_logs = docker run --rm -v monitoring-logs-python:/var/log alpine cat /var/log/system-monitor.log 2>$null
if ($python_file_logs) {
    $python_file_logs | Select-Object -Last 20
} else {
    Write-Host "No log file found" -ForegroundColor Yellow
}
