#!/usr/bin/env python3

import os
import argparse
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']
ORG = "metwork-framework"

argparser = argparse.ArgumentParser(
    description="get a list of github repositories for the given org")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("--topic", help="filter by this topic")
args = argparser.parse_args()

g = Github(TOKEN)
org = g.get_organization(args.ORG)
for repo in org.get_repos("public"):
    topics = repo.get_topics()
    if args.topic is not None:
        if args.topic not in topics:
            continue
    print(repo.name)