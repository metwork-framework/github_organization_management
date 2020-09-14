#!/usr/bin/env python3

import json
import argparse


argparser = argparse.ArgumentParser(
    description="get the latest (stable) release")
argparser.add_argument("RELEASE_FILE", help="releases.json file fullpath")
args = argparser.parse_args()

with open(args.RELEASE_FILE, "r") as f:
    c = f.read()
d = json.loads(c)

for release in d["actives"]:
    if release.get('latest', 0) == 1:
        print(release['branch'])
        break
else:
    raise Exception("no latest branch")
