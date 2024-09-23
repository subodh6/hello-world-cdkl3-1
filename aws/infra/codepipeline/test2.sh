#!/bin/bash

echo "Skipping yum update..."
echo "version controller"

# Update and install necessary packages
yum update -y
yum install jq -y
yum install zip -y

# List files in current directory
ls

# Source artifact reference
echo "Source artifact reference: $CODEBUILD_SOURCE_VERSION"

echo "Running build commands for lab stages..."
# Create build artifacts folder and copy necessary files
# Uncomment these lines if necessary
# mkdir build_artifacts
# cp cas-scheduler.war buildspec-lab.yml appspec.yml application_start.sh build_artifacts/

echo "Downloading finished"
echo "Extracting and assuming Deployer role for cross account"

# Define parameter name for SSM role
param_name="/matson-hello-world/$STAGE/deploy/role"

# Assume the deployer role using AWS SSM and STS
DEPLOY_ROLE=$(aws ssm get-parameter --name "$param_name" --with-decryption | jq -r ".Parameter.Value")
role=$(aws sts assume-role --role-arn "$DEPLOY_ROLE" --role-session-name ohana-api-deployer-session --duration-seconds 1800)

# Extract AWS credentials from the role
KEY=$(echo $role | jq -r ".Credentials.AccessKeyId")
SECRET=$(echo $role | jq -r ".Credentials.SecretAccessKey")
TOKEN=$(echo $role | jq -r ".Credentials.SessionToken")

# Export AWS credentials to environment
export AWS_ACCESS_KEY_ID=$KEY
export AWS_SESSION_TOKEN=$TOKEN
export AWS_SECRET_ACCESS_KEY=$SECRET
export AWS_DEFAULT_REGION=us-east-1

# Zip the deployment package
echo "Zipping files for codedeploy"
cd build_artifacts
DEPLOYMENT_PACKAGE_NAME="deployment-package-$(date +"%Y%m%d%H%M%S").zip"

# Update the WAR file reference in the appspec.yml
sed -i "s|{{WAR_FILE_NAME}}|cas-scheduler.war|g" appspec.yml

# Zip the necessary files
zip -r $DEPLOYMENT_PACKAGE_NAME appspec.yml application_start.sh cas-scheduler.war

# Copy the deployment package to the cross-account S3 bucket
echo "Copying zipped files to cross-account S3 bucket"
aws s3 cp $DEPLOYMENT_PACKAGE_NAME "$CROSS_ACCOUNT_S3_BUCKET_PATH/$DEPLOYMENT_PACKAGE_NAME"

# Verify the current AWS identity
aws sts get-caller-identity

# Start CodeDeploy deployment
echo "Codedeploy deployment started"
aws deploy create-deployment \
    --application-name cas-scheduler-admin1-application \
    --deployment-config-name CodeDeployDefault.OneAtATime \
    --deployment-group-name cas-scheduler-admin1-deploygroup \
    --description "Deployment Description" \
    --s3-location bucket=$CROSS_ACCOUNT_S3_BUCKET,bundleType=zip,key=$DEPLOYMENT_PACKAGE_NAME \
    --region us-east-1

# Wait for deployment to complete
echo "Waiting for deployment to complete..."
deploymentId=$(aws deploy list-deployments \
    --application-name cas-scheduler-admin1-application \
    --deployment-group-name cas-scheduler-admin1-deploygroup \
    --region us-east-1 --query 'deployments[0]' --output text)

aws deploy wait deployment-successful --deployment-id "$deploymentId" --region us-east-1

echo "Deployment finished"
