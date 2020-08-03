#!/usr/bin/env python3

import os
import argparse
import json
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']
ORG = "metwork-framework"

argparser = argparse.ArgumentParser(
    description="get a list of github repositories for the given org")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("--topic", help="filter by this topic")
argparser.add_argument("--json", action="store_true", help="json output")
args = argparser.parse_args()

g = Github(TOKEN)
org = g.get_organization(args.ORG)
repos = []
for repo in org.get_repos("public"):
    topics = repo.get_topics()
    if args.topic is not None:
        if args.topic not in topics:
            continue
    repos.append(repo.name)

if args.json:
    print(json.dumps(repos, indent=4))
else:
    for repo in repos:
        print(repo)
