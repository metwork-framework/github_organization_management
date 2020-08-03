#!/usr/bin/env python3

import os
import argparse
import sys
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']

argparser = argparse.ArgumentParser(
    description="get integration level")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("REPO", help="repo name")
args = argparser.parse_args()

g = Github(TOKEN)
repo = g.get_repo("%s/%s" % (args.ORG, args.REPO))
topics = repo.get_topics()
for i in (5, 4, 3, 2, 1, 0):
    if "integration-level-%i" % i in topics:
        print(i)
        sys.exit(0)
print(0)
sys.exit(0)
