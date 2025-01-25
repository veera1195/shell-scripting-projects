#!/bin/bash
# Declaring Array
services=("nginx.service" "cron.service" "systemd-timesyncd.service")
# Loop
for service in "${services[@]}"; do
# Check the service status
if systemctl is-active --quiet "$service"; then
echo " $service are running fine"
else
#restart the service
systemctl restart "$service"
echo "$service restarted"
fi

done