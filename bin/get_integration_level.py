#!/usr/bin/env python3

import os
import json
import argparse
import sys

DIR = os.path.dirname(os.path.realpath(__file__))

argparser = argparse.ArgumentParser(
    description="get integration level")
argparser.add_argument("REPO", help="repo name")
args = argparser.parse_args()

with open(f"{DIR}/../repositories.json", "r") as f:
    c = f.read()
repositories = json.loads(c)

for repo in repositories:
    if repo["name"] != args.REPO:
        continue
    for i in (5, 4, 3, 2, 1, 0):
        if "integration-level-%i" % i in repo["topics"]:
            print(i)
            sys.exit(0)
