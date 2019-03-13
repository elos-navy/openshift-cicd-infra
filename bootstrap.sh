#!/bin/bash -x

./cleanup.sh

oc process -f templates/jenkins-clusterroles-template.yaml | oc create -f -
oc process -f templates/jenkins-template.yaml | oc create -f -
oc start-build bc/infra-pipeline -n cicd-jenkins
