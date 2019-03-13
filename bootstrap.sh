#!/bin/bash -x

./cleanup.sh

oc process -f templates/jenkins-project-template.yaml | oc create -f -
oc project cicd-jenkins

oc new-app jenkins-persistent --param VOLUME_CAPACITY=4Gi

oc process -f templates/jenkins-infra-pipeline-template.yaml | oc create -f -
oc process -f templates/jenkins-app-pipeline-template.yaml | oc create -f -

oc start-build bc/infra-pipeline -n cicd-jenkins
