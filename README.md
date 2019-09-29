# Devops Takehome Build/Deploy

## Build

### Requirements
- Working awscli
- Python 3.7
- Docker
- ECR Registry with a repo created

### Instructions
python build.py --registry-url \<ECR Registry URL\> --repository-name \<Repo name\>


 Example:
 ``` 
 python build.py \
  --registry-url 123456789012.dkr.ecr.us-east-1.amazonaws.com \
  --repository-name devops-takehome
  ```

## Deploy

### Requirements
- Working awscli
- Python 3.7
- kubectl
- Working kubeconfig
- Kubernetes cluster with CoreDNS

### Instructions
Configure the "image" field in k8s/app-deployment.yaml to use the Repo and tag.

Ensure credentials in k8s/app-deployment.yaml in DATABASE_URL env match config in k8s/postgres-configmap.yaml

python deploy.py --num_replicas \<number of replicas\>

Example: 
```
python deploy.py --num_replicas 2
```
