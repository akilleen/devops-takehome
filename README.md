# Devops Takehome Build/Deploy

## Demo Instructions
I have included a script that demos how the solutions works. Just run demo.sh.

### Requirements
- Working awscli
- Python 3.7
- Docker
- kubectl

### Summary
This solution will build a Kuberenetes cluster on EKS (defaulting to us-east-1), build a docker image, push it to an ECR repo, and deploy it to Kubernetes from there. 

## Create Cluster
create_cluster.sh

## Build

### Summary

The build script takes an ECR registry and a repo name as command line arguments. The --repository-name argument will require the directory name of the app to be the same. For example, if you use `--repository-name devops-takehome` the app must be in the `devops-takehome` folder at the root of the project.

The script will tag the images numerically, starting at 1 if there are no current images pushed. It then builds the container using a Dockerfile, tags it, and pushes it to ECR.

### Instructions
python build.py --registry-url \<ECR Registry URL\> --repository-name \<Repo name\>


 Example:
 ``` 
 python build.py \
  --registry-url 123456789012.dkr.ecr.us-east-1.amazonaws.com \
  --repository-name devops-takehome
  ```

## Deploy

### Summary

The deploy script takes an argument for the number of replicas. It simply grabs the manifests from the k8s directory and deploys it to the Kubernetes cluster configured in kubectl. The manifests in the k8s directory use a simple template for `$num_replicas`, rendering it to the `--num_replicas` argument. You can see this on line 20 of the app-deployment manifest. 

### Instructions
Configure the "image" field in k8s/app-deployment.yaml to use the Repo and tag.

Ensure credentials in k8s/app-deployment.yaml in DATABASE_URL env match config in k8s/postgres-configmap.yaml

python deploy.py --num_replicas \<number of replicas\>

Example: 
```
python deploy.py --num_replicas 2
```
