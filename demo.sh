#!/bin/bash

set -e

sanity_check () {
    if ! type $! > /dev/null; then
        >&2 echo "$1 not installed. Please install it."
        exit 1
    fi
}

sanity_check git
sanity_check aws
sanity_check python
sanity_check kubectl
sanity_check docker

#echo "Running cluster setup..."
#./create_cluster.sh
#
echo "Cloning git repo"
git clone https://github.com/gaingroundspeed/devops-takehome.git

echo "Creating ECR Registry"
REGISTRY_URL=$(aws ecr create-repository \
--repository-name devops-takehome \
| grep repositoryUri \
| awk {'print $2'} \
| tr -d \" \
| cut -d/ -f 1
)

echo "Running build"
python build.py --registry-url $REGISTRY_URL --repository-name devops-takehome

echo "Running deploy"
python deploy.py --num-replicas 1 --tag 1

echo "Waiting for app to deploy..."
kubectl rollout status deployment/devops-takehome

echo "Waiting for rollout..."
sleep 120

echo "Testing health check..."
LB_HOSTNAME=$(kubectl describe service devops-takehome \
| grep LoadBalancer\ Ingress | awk {'print $3'})
curl http://$LB_HOSTNAME/healthcheck
echo ""

echo "Posting a message..."
curl -X POST http://$LB_HOSTNAME/message \
-H "Content-Type: application/json" \
--data '{"message": "Test 1"}'
echo ""

echo "Getting the first test message"
curl http://$LB_HOSTNAME/message/1
echo ""

echo "Scaling up to 2 instances..."
python deploy.py --num-replicas 2 --tag 1
kubectl rollout status deployment/devops-takehome

echo "Posting another message..."
curl -X POST http://$LB_HOSTNAME/message \
-H "Content-Type: application/json" \
--data '{"message": "Test 2"}'
echo ""

echo "Getting the second test message"
curl http://$LB_HOSTNAME/message/2
echo ""

echo "Making a code change"
sed -i 's/OK/OkieDokie/' devops-takehome/app.py

echo "Running another build..."
python build.py --registry-url $REGISTRY_URL --repository-name devops-takehome

echo "Deploying new version"
python deploy.py --num-replicas 2 --tag 2

echo "Waiting for app to deploy..."
kubectl rollout status deployment/devops-takehome

echo "Check health again..."
curl http://$LB_HOSTNAME/healthcheck
echo ""

echo "Posting another message..."
curl -X POST http://$LB_HOSTNAME/message \
-H "Content-Type: application/json" \
--data '{"message": "Test 3"}'
echo ""

echo "Getting the third test message"
curl http://$LB_HOSTNAME/message/3
echo ""
