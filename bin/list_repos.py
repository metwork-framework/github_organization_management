#!/usr/bin/env python3

import os
import argparse
import json


DIR = os.path.dirname(os.path.realpath(__file__))

argparser = argparse.ArgumentParser(
    description="list repo names")
argparser.add_argument("--topic", help="topic filter")
args = argparser.parse_args()

with open(f"{DIR}/../repositories.json", "r") as f:
    c = f.read()
repositories = json.loads(c)

for repo in repositories:
    if args.topic is not None:
        if args.topic not in repo["topics"]:
            continue
    print(repo.name)
