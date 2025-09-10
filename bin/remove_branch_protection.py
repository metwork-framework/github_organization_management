#!/usr/bin/env python3

import os
import argparse
import time
from github import Github
from github import Auth

TOKEN = os.environ['GITHUB_TOKEN']

argparser = argparse.ArgumentParser(
    description="get integration level")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("REPO", help="repo name")
argparser.add_argument("BRANCH", help="branch name")
args = argparser.parse_args()

auth = Auth.Token(TOKEN)
g = Github(auth=auth)
repo = g.get_repo("%s/%s" % (args.ORG, args.REPO))
branch = repo.get_branch(args.BRANCH)
if branch.protected:
    branch.remove_admin_enforcement()
    # We wait a little bit
    time.sleep(3)
