#!/bin/bash
export REPONAME=$1
export REPOADDRESS=$2
export CHART=$3
export PROJECT=$4
export KIND=$5
export APIVERSION=$6
export IMAGENAME=$7

echo "Adding helm repo ${REPONAME} on ${REPOADDRESS}"
helm repo add $REPONAME $REPOADDRESS
echo "Pulling helm chart ${CHART}"
helm pull $CHART
export HELMCHARTARCHIVENAME=`ls ${CHART}*` 
echo "Pulled helm chart ${CHART}"

echo "Removing old operator at ${PROJECT}"
rm -rf ${PROJECT}
echo "Removed old operator"

echo "Building operator  in new project ${PROJECT} with Kind ${KIND} on ApiVersion ${APIVERSION}"
operator-sdk new $PROJECT --type=helm --kind=$KIND --api-version=$APIVERSION --helm-chart=./$HELMCHARTARCHIVENAME
echo "Build operator"

echo "Changing image-name ${IMAGENAME} in deployment-files"
cd ./$PROJECT
sed -i "s|REPLACE_IMAGE|${IMAGENAME}|g" deploy/operator.yaml
sed -i "s|REPLACE_IMAGE|${IMAGENAME}|g" deploy/operator.yaml
echo "changed to image-name"

echo "Adding to repository"
git config --global user.email "support@netzlink.com"
git config --global user.name "build-helm-operator-action"
git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
git pull github $GITHUB_REF --ff-only
git add .
git commit -m "Build operator ${PROJECT} for ${APIVERSION}/${KIND} with the operator-sdk with ${CHART}"
git push github HEAD:$GITHUB_REF

echo "ready..."

echo "::set-output name=time::$(date)"