<img src="./assets/netzlink_logo.png" alt="netzlink logo" height="50px" />

# build-helm-operator-action
![test](https://github.com/Netzlink/build-helm-operator-action/workflows/test/badge.svg?branch=master)   
An github action for building operators based on hel-chartsm via the redhat operator sdk

# Build
Add a workflow to your repository
_.github/workflows/example_workflow.yml_
```yaml
name: apache-operator
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build test operator
      uses: ./
      id: builder
    - name: Get the output time
      run: echo "The time was ${{ steps.builder.outputs.time }}"
      with:
        repository-name: 'bitnami'
        repository-address: 'https://charts.bitnami.com/bitnami'
        chart: 'bitnami/apache'
        project: 'test-apache-operator'
        kind: 'Apache'
        api-version: 'apache.netzlink.com/v1alpha1'
        container-image: 'netzlink/apache-operator'
```
This workflow is resposible for building your operator.  
To build the operator and push the container-image we use a different workflow
 _.github/workflows/operator_and_container_build_workflow.yml_  
 ```yaml

name: apache_operator_CI_Prod
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  schedule:
    - cron: '0 2 * * *' # Daily at 02:00
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: get_version
      run: echo ::set-env name=RELEASE_VERSION::$(echo ${GITHUB_SHA})

    - name: Build test operator version: ${{ env.RELEASE_VERSION }}
      uses: ./
      id: builder
    - name: Get the output time
      run: echo "The time was ${{ steps.builder.outputs.time }}"
      with:
        repository-name: 'bitnami'
        repository-address: 'https://charts.bitnami.com/bitnami'
        chart: 'bitnami/apache'
        project: 'test-apache-operator'
        kind: 'Apache'
        api-version: 'apache.netzlink.com/v1alpha1'
        container-image: "netzlink/apache-operator:${{ env.RELEASE_VERSION }}"

    - name: Publish netzlink/apache-operator:${{ env.RELEASE_VERSION }}
      uses: elgohr/Publish-Docker-Github-Action@master
      with:
        name: netzlink/apache-operator
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        dockerfile: ./test-apache-operator/build/Dockerfile
        context: ./test-apache-operator
        tags: "latest,${{ env.RELEASE_VERSION }}"
 ```
 *WARNING*  
 Your have to add your registry username and password as secret in preparation.

 # Deployment
 The deployment is the easy part | __oc__ for Openshift __kubectl__ for Kubernetes  
 Add your CustomRessourceDefinition  
 ```yaml
 oc create -f ./<PROJECT-NAME>/deploy/crds/<APIVERSION>_<KIND>s_crd.yaml
 ```
 Deploy the operator
 ```yaml
 oc create -f ./<PROJECT-NAME>/deploy/service_account.yaml
 oc create -f ./<PROJECT-NAME>/deploy/role.yaml
 oc create -f ./<PROJECT-NAME>/deploy/role_binding.yaml
 oc create -f ./<PROJECT-NAME>/deploy/operator.yaml
```
Wait for to be status running
```yaml
oc get pods -w
```
When running deploy your first instance with the test CustomRessource
```yaml
oc create -f ./<PROJECT-NAME>/deploy/crds/<APIVERSION_DOMAIN_PART>_<APIVERSION_VERSION_PART>_<KIND>_cr.yaml
```
Wait for to be status running
```yaml
oc get pods -w
```
Now you schould have a running instance via the operator.   

also have a look at:
 * Github actions
 * Redhat operator-sdk and OpenShift
 * Helm
 * Kubernetes

 Happy building!
