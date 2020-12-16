#!/usr/bin/env python3

import os
import argparse
import json


DIR = os.path.dirname(os.path.realpath(__file__))

argparser = argparse.ArgumentParser(
    description="get topics")
argparser.add_argument("REPO", help="repo name")
args = argparser.parse_args()

with open(f"{DIR}/../repositories.json", "r") as f:
    c = f.read()
repositories = json.loads(c)

for repo in repositories:
    if repo["name"] != args.REPO:
        continue
    print(json.dumps(repo["topics"], indent=4))
    break
