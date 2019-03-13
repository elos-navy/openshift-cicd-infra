#!/bin/bash -x

oc delete project cicd-tasks-dev
oc delete project cicd-tasks-prod
oc delete project cicd-components
oc delete project cicd-jenkins

oc delete clusterrolebinding jenkins-cluster-admin
