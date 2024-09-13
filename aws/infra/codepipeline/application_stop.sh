#!/bin/bash

# Assuming Tomcat is installed in /opt/apache-tomcat-10.1.18, adjust the path accordingly
TOMCAT_HOME="/opt/apache-tomcat-10.1.18"

# Stop Tomcat
sudo $TOMCAT_HOME/bin/shutdown.sh

# Wait for Tomcat to fully stop (adjust the sleep duration based on your application's shutdown time)
sleep 10

# Additional cleanup or pre-shutdown commands can be added here
# For example, you might want to delete temporary files or perform other cleanup tasks.