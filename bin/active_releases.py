#!/usr/bin/env python3

import json
import argparse


argparser = argparse.ArgumentParser(
    description="list active releases")
argparser.add_argument("RELEASE_FILE", help="releases.json file fullpath")
args = argparser.parse_args()

with open(args.RELEASE_FILE, "r") as f:
    c = f.read()
d = json.loads(c)

for release in d["actives"]:
    print("%s;%s;%s;%s" % (release['branch'], release['previous'],
                           release['tags'], release['title']))
