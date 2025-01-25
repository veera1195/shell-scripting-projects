#!/bin/bash
#
#
###########################################################################
#
#
###########################Script to check service status and restart it if required########################
#
#
#
##############################Owner: Bala###############################################################
set -e #exit on error
set -o pipefail #Fail if any command in pipeline fails

#Declare a variable
service="nginx"

# check if the service is active
if systemctl is-active --quiet $service;then
    echo "$service is active and running"

else 
    echo " $service is restarting"
    systemctl restart $service
    echo " $service service has been restarted"

fi


