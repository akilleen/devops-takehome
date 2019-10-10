from string import Template
import argparse
import subprocess
from os import listdir

def deploy_to_k8s(num_replicas, tag):
    config_files = listdir('k8s')
    for config_file in config_files:
        deployment = open(f"k8s/{config_file}")
        s = Template(deployment.read())
        parsed_deployment = s.substitute(num_replicas=num_replicas, tag=tag)
        print(f"Deploying {config_file}")
        kubectl_deploy(parsed_deployment)

def kubectl_deploy(deployment):
    p = subprocess.run(
        [
            'kubectl',
            'apply',
            '-f',
            '-'
        ],
        stdout=subprocess.PIPE,
        input=deployment,
        encoding='utf-8'
    )
    print(p.stdout)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--num-replicas',
        help='Number of app replicas',
        required=True
    )
    parser.add_argument(
        '--tag',
        help='Tag of app to deploy',
        required=True
    )
    args = parser.parse_args()

    deploy_to_k8s(args.num_replicas, args.tag)