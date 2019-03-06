#!/bin/bash -x

oc delete project cicd-tasks
oc delete project cicd-components
oc delete project cicd-jenkins

oc delete clusterrolebinding jenkins-cluster-admin
