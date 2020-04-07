#!/bin/bash
echo "adding git, curl"
apt-get update -y
apt-get install -y git curl
echo "Adding helm3"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
echo "Adding operator sdk"
curl -L https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu --output operator-sdk
chmod +x operator-sdk
mv operator-sdk /usr/bin
echo "Installed operator sdk at version $(operator-sdk version)"
echo "Removing curl"
apt-get -y remove curl
echo "Install ready"