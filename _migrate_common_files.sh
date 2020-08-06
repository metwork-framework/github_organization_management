#!/bin/bash

echo "Fixing $1..."

sed -i "s/cookiecutter.integration_level/INTEGRATION_LEVEL/g" "$1"
sed -i "s/cookiecutter.repo/REPO/g" "$1"
sed -i "s~https://github.com/metwork-framework/resources/blob/master/cookiecutter/_......cookiecutter.repo....../~https://github.com/metwork-framework/github_organization_management/blob/master/common_files/~g" "$1"
sed -i "s~https://github.com/metwork-framework/resources/blob/master/cookiecutter/_......REPO....../~https://github.com/metwork-framework/github_organization_management/blob/master/common_files/~g" "$1"
sed -i "s~https://github.com/metwork-framework/resources/blob/master/cookiecutter/......REPO....../~https://github.com/metwork-framework/github_organization_management/blob/master/common_files/~g" "$1"
sed -i "s~REPO_TOPICS~TOPICS~g" "$1"
