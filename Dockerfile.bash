# Dockerfile for Bash monitoring script
FROM ubuntu:22.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    procps \
    sysstat \
    bc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create log directory
RUN mkdir -p /var/log

# Copy scripts and env file
COPY info.sh /app/info.sh
COPY .env /app/.env

# Make script executable
RUN chmod +x /app/info.sh

# Set working directory
WORKDIR /app

# Set environment variables
ENV LOG_PATH=/var/log/system-monitor.log

# Run the monitoring script as the main process
CMD ["/app/info.sh", "5"]
