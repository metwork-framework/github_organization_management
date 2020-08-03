#!/bin/bash

echo "Fixing $1..."

sed -i "s/cookiecutter.integration_level/INTEGRATION_LEVEL/g" "$1"
sed -i "s/cookiecutter.repo/REPO/g" "$1"
