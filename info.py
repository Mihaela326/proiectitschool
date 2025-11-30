#!/usr/bin/env python3

"""
System Information Monitoring Script (Python)
Displays system info every x seconds with critical alerts
"""

import os
import sys
import time
import subprocess
import psutil
import logging
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Colors for output
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
GREEN = '\033[0;32m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

# Critical thresholds
RAM_THRESHOLD = 15
DISK_THRESHOLD = 90

# Log file path from .env or environment variable, with fallback default
LOG_FILE = os.getenv('LOG_PATH') or os.getenv('log_path', '/var/log/system-monitor.log')

# Setup logging
def setup_logger():
    """Setup logging to file with custom levels"""
    # Create log directory if it doesn't exist
    log_dir = os.path.dirname(LOG_FILE)
    if log_dir and not os.path.exists(log_dir):
        try:
            os.makedirs(log_dir, exist_ok=True)
        except Exception:
            pass
    
    logger = logging.getLogger('SystemMonitor')
    logger.setLevel(logging.DEBUG)
    
    # File handler
    try:
        file_handler = logging.FileHandler(LOG_FILE, mode='a')
        file_handler.setLevel(logging.DEBUG)
        
        # Format with timestamp and level
        formatter = logging.Formatter('[%(asctime)s] %(levelname)-8s: %(message)s', 
                                    datefmt='%Y-%m-%d %H:%M:%S')
        file_handler.setFormatter(formatter)
        
        logger.addHandler(file_handler)
    except Exception:
        pass
    
    return logger


class SystemMonitor:
    def __init__(self, interval=5):
        self.interval = interval
        self.alert_flag = False
        self.logger = setup_logger()

    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('clear' if os.name == 'posix' else 'cls')

    def print_header(self):
        """Print header with colors"""
        print(f"{BLUE}========================================{NC}")
        print(f"{BLUE}     System Information Monitor{NC}")
        print(f"{BLUE}========================================{NC}")

    def get_date_time(self):
        """Get current date and time"""
        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"{GREEN}Date and Time:{NC} {now}")
        self.logger.info(f"Date and Time: {now}")

    def get_linux_info(self):
        """Get Linux distribution and kernel information"""
        print(f"{GREEN}Linux Distribution:{NC}")
        
        try:
            # Try to read /etc/os-release
            os_info = {}
            if Path('/etc/os-release').exists():
                with open('/etc/os-release', 'r') as f:
                    for line in f:
                        key, value = line.strip().split('=', 1)
                        os_info[key] = value.strip('"')
                
                name = os_info.get('NAME', 'Unknown')
                version = os_info.get('VERSION_ID', 'Unknown')
                id_val = os_info.get('ID', 'Unknown')
                
                print(f"  OS: {name} {version}")
                print(f"  ID: {id_val}")
                self.logger.info(f"OS: {name} {version} (ID: {id_val})")
            else:
                print("  OS: Unable to determine (Linux detected)")
                self.logger.warning(f"OS: Unable to determine (Linux detected)")
        except Exception as e:
            print(f"  OS: Unable to determine - {str(e)}")
            self.logger.warning(f"OS: Unable to determine - {str(e)}")
        
        # Get kernel version
        try:
            kernel = subprocess.check_output(['uname', '-r']).decode().strip()
            print(f"{GREEN}Kernel:{NC} {kernel}")
            self.logger.info(f"Kernel: {kernel}")
        except:
            print(f"{GREEN}Kernel:{NC} Unable to determine")
            self.logger.warning("Kernel: Unable to determine")
        
        # Get hostname
        try:
            hostname = subprocess.check_output(['hostname']).decode().strip()
            print(f"{GREEN}Hostname:{NC} {hostname}")
            self.logger.info(f"Hostname: {hostname}")
        except:
            print(f"{GREEN}Hostname:{NC} Unable to determine")
            self.logger.warning("Hostname: Unable to determine")

    def get_load_average(self):
        """Get system load average"""
        try:
            load1, load5, load15 = os.getloadavg()
            print(f"{GREEN}Load Average:{NC} {load1:.2f}, {load5:.2f}, {load15:.2f}")
            self.logger.info(f"Load Average: {load1:.2f}, {load5:.2f}, {load15:.2f}")
        except Exception as e:
            print(f"{GREEN}Load Average:{NC} Unable to determine - {str(e)}")
            self.logger.warning(f"Load Average: Unable to determine - {str(e)}")

    def get_uptime(self):
        """Get system uptime"""
        try:
            uptime_result = subprocess.check_output(['uptime', '-p']).decode().strip()
            print(f"{GREEN}Uptime:{NC} {uptime_result}")
            self.logger.info(f"Uptime: {uptime_result}")
        except:
            try:
                boot_time = datetime.fromtimestamp(psutil.boot_time())
                uptime = datetime.now() - boot_time
                days = uptime.days
                hours, remainder = divmod(uptime.seconds, 3600)
                minutes, _ = divmod(remainder, 60)
                uptime_str = f"{days} days, {hours} hours, {minutes} minutes"
                print(f"{GREEN}Uptime:{NC} {uptime_str}")
                self.logger.info(f"Uptime: {uptime_str}")
            except Exception as e:
                print(f"{GREEN}Uptime:{NC} Unable to determine - {str(e)}")
                self.logger.warning(f"Uptime: Unable to determine - {str(e)}")

    def get_cpu_usage(self):
        """Get CPU usage"""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            print(f"{GREEN}CPU Usage:{NC} {cpu_percent}%")
            self.logger.info(f"CPU Usage: {cpu_percent}%")
        except Exception as e:
            print(f"{GREEN}CPU Usage:{NC} Unable to determine - {str(e)}")
            self.logger.warning(f"CPU Usage: Unable to determine - {str(e)}")

    def get_memory_usage(self):
        """Get memory usage"""
        try:
            memory = psutil.virtual_memory()
            print(f"{GREEN}Memory Usage:{NC}")
            print(f"  Total: {self.format_bytes(memory.total)}")
            print(f"  Used: {self.format_bytes(memory.used)}")
            print(f"  Available: {self.format_bytes(memory.available)}")
            print(f"  Percentage: {memory.percent:.1f}%")
            self.logger.info(f"Memory Usage: Total={self.format_bytes(memory.total)}, Used={self.format_bytes(memory.used)}, Available={self.format_bytes(memory.available)}, Percentage={memory.percent:.1f}%")
        except Exception as e:
            print(f"{GREEN}Memory Usage:{NC} Unable to determine - {str(e)}")
            self.logger.warning(f"Memory Usage: Unable to determine - {str(e)}")

    def get_disk_usage(self):
        """Get disk usage"""
        print(f"{GREEN}Disk Usage:{NC}")
        try:
            for partition in psutil.disk_partitions():
                if partition.fstype:  # Only show filesystems with a type
                    try:
                        usage = psutil.disk_usage(partition.mountpoint)
                        device = partition.device
                        total = self.format_bytes(usage.total)
                        used = self.format_bytes(usage.used)
                        percent = usage.percent
                        
                        print(f"  {device:<20} {used} / {total} ({percent}%)")
                        self.logger.info(f"Disk Usage: {device} = {used} / {total} ({percent}%)")
                    except PermissionError:
                        pass
        except Exception as e:
            print(f"  Unable to determine - {str(e)}")
            self.logger.warning(f"Disk Usage: Unable to determine - {str(e)}")

    def check_alerts(self):
        """Check for critical alerts"""
        print("")
        print(f"{BLUE}========== ALERTS =========={NC}")
        
        self.alert_flag = False
        
        # Check RAM usage
        try:
            memory = psutil.virtual_memory()
            available_percent = 100 - memory.percent
            
            if available_percent < RAM_THRESHOLD:
                alert_msg = f"RAM available: {available_percent:.1f}% (threshold: {RAM_THRESHOLD}%)"
                print(f"{RED}[CRITICAL] {alert_msg}{NC}")
                self.logger.critical(alert_msg)
                self.alert_flag = True
        except Exception as e:
            print(f"  RAM check error: {str(e)}")
            self.logger.warning(f"RAM check error: {str(e)}")
        
        # Check Disk usage
        try:
            for partition in psutil.disk_partitions():
                if partition.fstype:
                    try:
                        usage = psutil.disk_usage(partition.mountpoint)
                        if usage.percent > DISK_THRESHOLD:
                            alert_msg = f"Disk usage over {DISK_THRESHOLD}% - {partition.device}: {usage.percent}%"
                            print(f"{RED}[CRITICAL] {alert_msg}{NC}")
                            self.logger.critical(alert_msg)
                            self.alert_flag = True
                    except PermissionError:
                        pass
        except Exception as e:
            print(f"  Disk check error: {str(e)}")
            self.logger.warning(f"Disk check error: {str(e)}")
        
        if not self.alert_flag:
            print(f"{GREEN}No critical alerts{NC}")
            self.logger.info("No critical alerts")
        
        print(f"{BLUE}==========================={NC}")

    @staticmethod
    def format_bytes(bytes_value):
        """Format bytes to human readable format"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes_value < 1024.0:
                return f"{bytes_value:.1f}{unit}"
            bytes_value /= 1024.0
        return f"{bytes_value:.1f}PB"

    def run(self):
        """Main monitoring loop"""
        print(f"Starting system monitor (refreshing every {self.interval} seconds)...")
        time.sleep(2)
        
        try:
            while True:
                self.clear_screen()
                self.print_header()
                print("")
                
                self.get_date_time()
                print("")
                
                self.get_linux_info()
                print("")
                
                self.get_load_average()
                print("")
                
                self.get_uptime()
                print("")
                
                self.get_cpu_usage()
                print("")
                
                self.get_memory_usage()
                print("")
                
                self.get_disk_usage()
                print("")
                
                self.check_alerts()
                
                print("")
                print(f"{YELLOW}Next update in {self.interval} seconds (press Ctrl+C to exit)...{NC}")
                
                time.sleep(self.interval)
        
        except KeyboardInterrupt:
            print(f"\n{YELLOW}Monitor stopped by user.{NC}")
            sys.exit(0)


def main():
    """Main entry point"""
    interval = 5
    
    # Parse command line arguments
    if len(sys.argv) > 1:
        try:
            interval = int(sys.argv[1])
            if interval < 1:
                print(f"{RED}Error: Interval must be at least 1 second.{NC}")
                sys.exit(1)
        except ValueError:
            print(f"{RED}Error: Invalid interval. Please provide a number (seconds).{NC}")
            sys.exit(1)
    
    monitor = SystemMonitor(interval)
    monitor.run()


if __name__ == '__main__':
    main()
