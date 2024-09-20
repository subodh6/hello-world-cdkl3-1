import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as codedeploy from 'aws-cdk-lib/aws-codedeploy';
import { config } from './config';

export interface CicdPipelineProps extends cdk.StackProps {}

export class crossaccount extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: CicdPipelineProps) {
    super(scope, id, props);

    // Create an S3 bucket for CodePipeline artifacts with stack name in the bucket name
    const codePipelineBucket = new s3.Bucket(this, 'CodePipelineBucket', {
      bucketName: `${this.stackName}-lab`,
      lifecycleRules: [{
        id: config.bucketLifecyclePolicy.id,
        enabled: config.bucketLifecyclePolicy.status === 'Enabled',
        prefix: config.bucketLifecyclePolicy.prefix,
        transitions: [{
          storageClass: s3.StorageClass.INTELLIGENT_TIERING,
          transitionAfter: cdk.Duration.days(config.bucketLifecyclePolicy.transitionInDays),
        }],
        expiration: cdk.Duration.days(config.bucketLifecyclePolicy.expirationInDays),
      }],
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // Create CodeDeploy Role with stack name in the role name
    const codeDeployRole = new iam.Role(this, 'CodeDeployRole', {
      roleName: `${this.stackName}-codedeploy-role`, // Add stack name to the role name
      assumedBy: new iam.ServicePrincipal('codedeploy.amazonaws.com'),
    });
    
    // Attach the AWS-managed policy 'AWSCodeDeployRole'
    codeDeployRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('AWSCodeDeployRole'));
    

    // Create CodeDeploy Application with stack name in the application name
    const codeDeployApplication = new codedeploy.CfnApplication(this, 'CodeDeployApplication', {
      applicationName: `${this.stackName}-application`,
      computePlatform: 'Server',
    });

    // Create CodeDeploy Deployment Group with stack name in the deployment group name
    new codedeploy.CfnDeploymentGroup(this, 'CodeDeployDeploymentGroup', {
      applicationName: codeDeployApplication.applicationName || `${this.stackName}-application`,
      deploymentGroupName: `${this.stackName}-deploygroup`,
      serviceRoleArn: codeDeployRole.roleArn,
      deploymentConfigName: 'CodeDeployDefault.AllAtOnce',
      ec2TagFilters: [
        {
          key: 'Name',
          value: 'matson', // Replace with your EC2 tag
          type: 'KEY_AND_VALUE',
        },
      ],
      autoRollbackConfiguration: {
        enabled: true,
        events: [
          'DEPLOYMENT_FAILURE',
        ],
      },
      deploymentStyle: {
        deploymentType: 'IN_PLACE',
        deploymentOption: 'WITHOUT_TRAFFIC_CONTROL',
      },
    });
  }
}
