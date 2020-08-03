#!/bin/bash

echo "Fixing $1..."
set -i "s/cookiecutter.integration_level/INTEGRATION_LEVEL/g" $1
set -i "s/cookiecutter.repo/REPO/g" $1
