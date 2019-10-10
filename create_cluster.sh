#!/bin/bash

set -e 

error_exit () {
    >&2 echo "An error was encountered. Bailing out!"
    exit 1
}

echo "Installing eksctl"

if [ ! -d bin ]; then
    mkdir bin
fi

curl \
--silent \
--location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" \
| tar xz -C ./bin \
|| error_exit

echo 'Creating EKS Cluster'
bin/eksctl create cluster \
--name helloCluster \
--version 1.14 \
--nodegroup-name nodegroup \
--node-type t3.medium \
--nodes 1 \
--nodes-min 1 \
--nodes-max 1 \
--node-ami auto \
--zones=us-east-1a,us-east-1b \
 || error_exit

echo "Testing k8s connectivity..."
kubectl get nodes || error_exit

echo "Cluster successfully configured!"