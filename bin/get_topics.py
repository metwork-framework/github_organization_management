#!/usr/bin/env python3

import os
import argparse
import json
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']

argparser = argparse.ArgumentParser(
    description="get topics")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("REPO", help="repo name")
args = argparser.parse_args()

g = Github(TOKEN)
repo = g.get_repo("%s/%s" % (args.ORG, args.REPO))
topics = repo.get_topics()
print(json.dumps(topics, indent=4))
