#!/bin/bash

# Configurable variables
SERVICES=("apache2" "mysql")  # List of services to monitor
RETRY_COUNT=3                  # Number of retries before restarting
LOG_FILE="/var/log/service_monitor.log" #Log Files saved inside the path
ALERT_EMAIL="admin@example.com"  # Email has to be sent to the above DL

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') : $message" | tee -a "$LOG_FILE"
}

# Function to send alert
send_alert() {
    local service="$1"
    local status="$2"
    echo -e "Subject: Service Alert: $service\n\nService $service is $status on $(hostname) at $(date)." |
        sendmail "$ALERT_EMAIL"
}

# Monitor services
for service in "${SERVICES[@]}"; do
    log_message "Checking service: $service"

    # Check if service is active
    if ! systemctl is-active --quiet "$service"; then
        log_message "Service $service is down. Attempting to recover."
        send_alert "$service" "DOWN"

        # Retry mechanism
        for ((i = 1; i <= RETRY_COUNT; i++)); do
            log_message "Retry $i/$RETRY_COUNT for $service."
            sleep 5
            if systemctl is-active --quiet "$service"; then
                log_message "Service $service is back up after retry $i."
                break
            fi
        done

        # Restart the service if retries fail
        if ! systemctl is-active --quiet "$service"; then
            log_message "Restarting $service after failed retries."
            systemctl restart "$service"

            # Verify restart
            if systemctl is-active --quiet "$service"; then
                log_message "Service $service restarted successfully."
            else
                log_message "Failed to restart $service. Manual intervention required."
                send_alert "$service" "FAILED TO RESTART"
            fi
        fi
    else
        log_message "Service $service is running fine."
    fi

done

log_message "Service monitoring script completed."
