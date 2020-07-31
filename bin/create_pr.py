#!/usr/bin/env python3

import os
import argparse
from github import Github

TOKEN = os.environ['GITHUB_TOKEN']

argparser = argparse.ArgumentParser(
    description="create a PR")
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("REPO", help="repo name")
argparser.add_argument("HEAD", help="PR head")
argparser.add_argument("--title", help="pr title", default="WIP")
argparser.add_argument("--body", help="pr body", default="")
argparser.add_argument("--base", help="pr base", default="master")
args = argparser.parse_args()

g = Github(TOKEN)
repo = g.get_repo("%s/%s" % (args.ORG, args.REPO))
print(repo.create_pull(title=args.title, body=args.body,
                       head=args.HEAD, base=args.base))