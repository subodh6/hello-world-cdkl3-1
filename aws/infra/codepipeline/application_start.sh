#!/bin/bash

# Assuming Tomcat is installed in /opt/apache-tomcat-10.1.18, adjust the path accordingly
TOMCAT_HOME="/opt/apache-tomcat-9.0.93/"
 
sudo $TOMCAT_HOME/bin/shutdown.sh
sudo rm -rf $TOMCAT_HOME/webapps/*
sudo mv /tmp/cas-scheduler.war /tmp/ROOT.war
sudo cp -R /tmp/*.war $TOMCAT_HOME/webapps
sudo $TOMCAT_HOME/bin/startup.sh

# Wait for Tomcat to fully stop (adjust the sleep duration based on your application's shutdown time)
# sleep 10

# Start Tomcat
# sudo $TOMCAT_HOME/bin/startup.sh

# Wait for Tomcat to fully start (adjust the sleep duration based on your application's startup time)
# sleep 30

# Additional commands or configurations after Tomcat has started can be added here
# For example, you might want to tail the catalina.out log file for debugging:
# tail -f $TOMCAT_HOME/logs/catalina.out