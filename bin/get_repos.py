#!/usr/bin/env python3

import os
import argparse
import json
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']
ORG = "metwork-framework"

argparser = argparse.ArgumentParser(
    description="get a list of github repositories as json for the given org")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("--topic", help="filter by this topic")
args = argparser.parse_args()

repos = []

g = Github(TOKEN)
org = g.get_organization(args.ORG)
for repo in org.get_repos("public"):
    topics = repo.get_topics()
    if args.topic is not None:
        if args.topic not in topics:
            continue
    r = {
        "name": repo.name,
        "branches": [x.name for x in repo.get_branches()],
        "topics": topics,
        "integration_levels": []
    }
    for il in (1, 2, 3, 4, 5):
        if ("integration-level-%i" % il) in topics:
            for j in range(1, il + 1):
                r["integration_levels"].append(j)
            break
    repos.append(r)
print(json.dumps(repos, indent=4))
