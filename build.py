import argparse
import subprocess
import shlex
import json

parser = argparse.ArgumentParser()
parser.add_argument(
    '--registry-url',
    help='URL of Docker Repo',
    required=True
)
parser.add_argument(
    '--repository-name',
    help='Name of repo',
    required=True
)

args = parser.parse_args()

def build_container(repo_name, tag):
    print(f"Building {repo_name} with tag {tag}...")
    p = subprocess.Popen(
        [
            'docker',
            'build',
            '-t',
            f"{repo_name}:{tag}",
            '.'
        ]
    )
    return_code = p.wait()
    check_return_code(return_code)


def tag_container(registry, repo_name, tag):
    print(f"Tagging container as {registry}/{repo_name}:{tag}...")
    p = subprocess.Popen(
        [
            'docker',
            'tag',
            f"{repo_name}:{tag}",
            f"{registry}/{repo_name}:{tag}"
        ]
    )
    return_code = p.wait()
    check_return_code(return_code)

def push_container(registry, repo_name, tag):
    print('Building container...')
    ecr_login()
    p = subprocess.Popen(
        [
            'docker',
            'push',
            f"{registry}/{repo_name}:{tag}"
        ]
    )
    return_code = p.wait()
    check_return_code(return_code)

def ecr_login():
    login = subprocess.check_output(
        [
            'aws',
            'ecr',
            'get-login',
            '--no-include-email'
        ]
    )
    p = subprocess.Popen(shlex.split(login.decode()))
    p.wait()

def get_latest_tag(repo):
    tags = []
    latest_tag = 0
    images = subprocess.check_output(
        [
            'aws',
            'ecr',
            'list-images',
            '--repository-name',
            repo
        ]
    )
    images_json = json.loads(images.decode())
    for image in images_json['imageIds']:
        tags.append(image['imageTag'])
    if not tags:
        print("No tags found yet.")
    else:
        tags.sort()
        latest_tag = int(tags[0])
    return latest_tag

def check_return_code(code):
    if code != 0:
        print(f"Failed. Error code: {code}")
        exit(1)

if __name__ == "__main__":
    new_tag = get_latest_tag(args.repository_name) + 1
    build_container(args.repository_name, new_tag)
    tag_container(args.registry_url, args.repository_name, new_tag)
    push_container(args.registry_url, args.repository_name, new_tag)