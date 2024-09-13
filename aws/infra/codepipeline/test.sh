#!/bin/bash
 
VERSION="0.2"
 
# Install phase

echo "Skipping yum update..."

pip install boto3
 
# Pre-build phase

echo "version controller"

sudo yum update -y

sudo yum install jq -y

sudo yum install zip -y

pip install requests

pip install ruamel.yaml
 
# Build phase

echo "Source artifact reference: $CODEBUILD_SOURCE_VERSION"

echo "Build started"
 

# cp -r aws/infra/codepipeline/* Ohana-Springboot/
 

# cd Ohana-Springboot || exit
 

# ls
 

# export CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token --domain matson --domain-owner 891377353125 --region us-east-1 --query authorizationToken --output text)
 

echo "Integration of CodeArtifact and authorizing"
 

echo "Build Initiated"

mvn clean install -s settings.xml

echo "Build Completed"
 
# Post-build phase

echo "Downloading Required files for codedeploy"
 

cp target/cas-scheduler-admin-1.0.2.war .
 

mv cas-scheduler-admin-1.0.2.war cas-scheduler.war
 

mkdir build_artifacts

cp cas-scheduler.war buildspec-lab.yml appspec.yml application_start.sh build_artifacts/
 

echo "Build artifacts prepared:"

ls build_artifacts/

 
