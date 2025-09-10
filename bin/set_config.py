#!/usr/bin/env python3

import os
import json
import requests
import logging
from github import Github
from github import Auth

TOKEN = os.environ["GITHUB_TOKEN"]
HEADERS_WITH_TOKEN = {"Authorization": "token %s" % TOKEN}
DIR = os.path.dirname(os.path.realpath(__file__))

BP_ENFORCE_ADMINS = True
BP_REQUIRED_STATUS_CHECK_STRICT = True
BP_REQUIRED_STATUS_CHECK_CONTEXTS = ["license/cla"]
BP_REQUIRED_PR_REVIEWS_DISMISS = False
BP_REQUIRED_PR_REVIEWS_OWNERS = False
BP_REQUIRED_PR_REVIEWS_COUNT = 1


def compare_list_of_strings(a, b):
    if len(a) != len(b):
        return False
    return len(set(a) & set(b)) == len(a)


with open(f"{DIR}/../repositories.json", "r") as f:
    c = f.read()
repositories = json.loads(c)
with open(f"{DIR}/../labels.json", "r") as f:
    c = f.read()
labels = json.loads(c)
with open(f"{DIR}/../releases.json", "r") as f:
    c = f.read()
releases = json.loads(c)

auth=Auth.Token(TOKEN)
g = Github(auth=auth)
for repository in repositories:
    repo = g.get_repo("%s/%s" % ("metwork-framework", repository["name"]))
    extra_labels = []
    if 4 in repository["integration_levels"]:
        for release in releases["actives"]:
            title = release["title"]
            extra_labels.append({
                "name": "backport-to-%s" % title,
                "title": "backport-to-%s" % title,
                "color": "eb6420"
            })
    # LABELS
    for lbl in labels + extra_labels:
        if (
            lbl["title"] not in repository["labels"]
            or lbl["color"] != repository["labels"][lbl["title"]]
        ):
            if lbl["title"] in repository["labels"]:
                print(
                    "deleting label: %s in repository: %s"
                    % (lbl["title"], repository["name"])
                )
                try:
                    res = requests.delete(
                        repo.labels_url.replace("{/name}", "/%s" % lbl["title"]),
                        headers=HEADERS_WITH_TOKEN,
                    )
                    res.raise_for_status()
                except Exception:
                    logging.warning(
                        "exception during delete_label(%s) on repo: %s"
                        % (lbl["title"], repository["name"]),
                        exc_info=True,
                    )
            print(
                "missing label: %s in repository: %s"
                % (lbl["title"], repository["name"])
            )
            try:
                repo.create_label(lbl["title"], lbl["color"])
            except Exception:
                logging.warning(
                    "exception during create_label(%s, %s) on repo: %s"
                    % (lbl["title"], lbl["color"], repository["name"]),
                    exc_info=True,
                )
    # BRANCH PROTECTION
    if 4 not in repository["integration_levels"]:
        continue
    for release in releases["actives"] + releases["persistents"]:
        branch_name = release["branch"]
        if branch_name not in repository["branches"]:
            continue
        bprotection = repository["branch_protections"].get(branch_name, {})
        enforce = bprotection.get("enforce_admins", False)
        strict = bprotection.get("required_status_checks", {}).get("strict", False)
        contexts = bprotection.get("required_status_checks", {}).get("contexts", [])
        dismiss = bprotection.get("required_pull_request_reviews", {}).get(
            "dismiss_stale_reviews", False
        )
        owners = bprotection.get("required_pull_request_reviews", {}).get(
            "require_code_owner_reviews", False
        )
        count = bprotection.get("required_pull_request_reviews", {}).get(
            "required_approving_review_count", 0
        )
        if (
            enforce != BP_ENFORCE_ADMINS
            or strict != BP_REQUIRED_STATUS_CHECK_STRICT
            or dismiss != BP_REQUIRED_PR_REVIEWS_DISMISS
            or owners != BP_REQUIRED_PR_REVIEWS_OWNERS
            or count != BP_REQUIRED_PR_REVIEWS_COUNT
            or not compare_list_of_strings(contexts, BP_REQUIRED_STATUS_CHECK_CONTEXTS)
        ):
            print(
                "create branch protection for %s/%s" % (repository["name"], branch_name)
            )
            branch = repo.get_branch(branch_name)
            if branch.protected:
                print(
                    "remove branch protection for %s/%s"
                    % (repository["name"], branch_name)
                )
                try:
                    branch.remove_protection()
                except Exception:
                    logging.warning(
                        "exception during remove_protection(%s) on repo: %s"
                        % (branch_name, repository["name"]),
                        exc_info=True,
                    )
            try:
                branch.edit_protection(
                    strict=BP_REQUIRED_STATUS_CHECK_STRICT,
                    contexts=BP_REQUIRED_STATUS_CHECK_CONTEXTS,
                    enforce_admins=BP_ENFORCE_ADMINS,
                    dismiss_stale_reviews=BP_REQUIRED_PR_REVIEWS_DISMISS,
                    require_code_owner_reviews=BP_REQUIRED_PR_REVIEWS_OWNERS,
                    required_approving_review_count=BP_REQUIRED_PR_REVIEWS_COUNT
                )
            except Exception:
                logging.warning(
                    "exception during edit_protection(%s) on repo: %s"
                    % (branch_name, repository["name"]),
                    exc_info=True,
                )
