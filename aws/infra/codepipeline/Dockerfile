FROM tomcat:8.0
USER root
WORKDIR /usr/local/tomcat/webapps
COPY *.war /usr/local/tomcat/webapps/
CMD ["catalina.sh","run"]
