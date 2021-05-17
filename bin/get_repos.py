#!/usr/bin/env python3

import os
import itertools
import argparse
import json
from github import Github

TOKEN = os.environ["GITHUB_TOKEN"]
ORG = "metwork-framework"
LIMIT_TO_REPO = os.environ.get("LIMIT_TO_REPO", "")

argparser = argparse.ArgumentParser(
    description="get a list of github repositories for the given org"
)
argparser.add_argument("ORG", help="organization name")
argparser.add_argument("--topic", help="filter by this topic")
args = argparser.parse_args()

g = Github(TOKEN)
org = g.get_organization(args.ORG)
repos = []
for repo in itertools.chain(org.get_repos("public"), org.get_repos("private")):
    if repo.archived:
        continue
    if LIMIT_TO_REPO:
        if repo.name != LIMIT_TO_REPO:
            continue
    topics = repo.get_topics()
    if args.topic is not None:
        if args.topic not in topics:
            continue
    tmp = {
        "name": repo.name,
        "branches": [x.name for x in repo.get_branches()],
        "topics": topics,
        "integration_levels": [],
        "labels": {x.name: x.color for x in repo.get_labels()},
    }
    for il in (1, 2, 3, 4, 5):
        if ("integration-level-%i" % il) in topics:
            for j in range(1, il + 1):
                tmp["integration_levels"].append(j)
            break
    tmp["branch_protections"] = {}
    for branch in repo.get_branches():
        if branch.protected:
            protection = branch.get_protection()
            tmp["branch_protections"][branch.name] = {
                "enforce_admins": protection.enforce_admins
            }
            if protection.required_status_checks is None:
                tmp["branch_protections"][branch.name]["required_status_checks"] = None
            else:
                tmp["branch_protections"][branch.name]["required_status_checks"] = {
                    "strict": protection.required_status_checks.strict,
                    "contexts": protection.required_status_checks.contexts,
                }
            reviews = protection.required_pull_request_reviews
            if reviews is None:
                tmp["branch_protections"][branch.name][
                    "required_pull_request_reviews"
                ] = None
            else:
                review_count = reviews.required_approving_review_count
                tmp["branch_protections"][branch.name][
                    "required_pull_request_reviews"
                ] = {
                    "dismiss_stale_reviews": reviews.dismiss_stale_reviews,
                    "require_code_owner_reviews": reviews.require_code_owner_reviews,
                    "required_approving_review_count": review_count,
                }
    repos.append(tmp)

print(json.dumps(repos, indent=4))
