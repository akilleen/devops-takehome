# Devops Takehome Build/Deploy

## Demo Instructions
I have included a script that demos how the solution works. Just run demo.sh.

### Local Requirements
- Working awscli with admin access (Tested with v1.16.248)
- Default region in awscli set to us-east-1
- Python 3.7 (May work with 3.6+, but only tested with 3.7.4)
- Docker (Tested with v18.06.1-ce)
- kubectl (Tested with v1.16.1)

### Summary
This solution will build a Kuberenetes cluster on EKS (defaulting to us-east-1), git clone the app from the repo, build a docker image, push it to an ECR repo, and deploy it to Kubernetes. 

The demo script will run through all of this automatically. It will also test the application, scale the application up, and do another build/deploy after a quick code change. 

## Create Cluster

### Summary
This is a simple bash script that uses eksctl to stand up an EKS cluster with a worker node. I have forced it to use us-east-1a and us-east-1b since I was running into issues with AWS while standing up on other AZs.

## Instructions

```
create_cluster.sh
```

## Build

### Summary

The build script takes an ECR registry and a repo name as command line arguments. The --repository-name argument will require the directory name of the app to be the same. For example, if you use `--repository-name devops-takehome` the app must be in the `devops-takehome` folder at the root of the project.

The script will tag the images incrementally, starting at 1 if there are no current images pushed. It then builds the container using a Dockerfile, tags it, and pushes it to ECR.

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

The deploy script takes an argument for the number of replicas and the tag to deploy. It simply grabs the manifests from the k8s directory and deploys it to the Kubernetes cluster configured in kubectl. The manifests in the k8s directory use a simple template for the `$num_replicas` and `$tag` command line args. You can see this on line 20 and 28 of the app-deployment manifest. 

### Instructions
python deploy.py --num_replicas \<number of replicas\> --tag <tag>

Example: 
```
python deploy.py --num_replicas 2 --tag 1
```
