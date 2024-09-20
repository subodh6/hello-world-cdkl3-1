curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs
sudo npm install -g typescript
npm install aws-cdk
npm install aws-cdk-lib
npm install constructs
npx cdk synth
npx cdk deploy