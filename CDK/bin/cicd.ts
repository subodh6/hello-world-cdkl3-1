import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
// import { cicdstack } from '../lib/cicd-stack';
import { crossaccount } from '../lib/cross-account';
const app = new cdk.App();

// new cicdstack(app, 'cicdstack', {
//   env: { account: '637423476845', region: 'ap-south-1' },
// });

new crossaccount(app, 'cas-scheduler-admin-l3', {
  env: { account: '954503069243', region: 'us-east-1' },
});
