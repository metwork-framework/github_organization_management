#!/usr/bin/env python3

import os
import argparse
import time
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']

argparser = argparse.ArgumentParser(
    description="get integration level")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("REPO", help="repo name")
argparser.add_argument("BRANCH", help="branch name")
args = argparser.parse_args()

g = Github(TOKEN)
repo = g.get_repo("%s/%s" % (args.ORG, args.REPO))
branch = repo.get_branch(args.BRANCH)
if branch.protected:
    branch.set_admin_enforcement()
    # We wait a little bit
    time.sleep(3)
