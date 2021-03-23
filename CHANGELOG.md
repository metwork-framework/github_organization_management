# CHANGELOG

## [Unreleased]

### New Features

- add branch protection
- introduce common files (#2)
- add copy integration branch feature
- apply for all repositories
- migrate resources common_files (#5)
- first implementation of changelog generation
- changelog generation for integration-level >=4 (part1)
- add cron to copy integration branch 
- changelog generation for release branches (#21)
- add copy_branch workflow
- introduce release workflow
- new changelog generator tool (ghtc) (#42)
- add common files to build Metwork modules with github actions when "github-actions" is in repository topics (#46)
- trigger from drone with github action repository-dispatch (if "trigger-github" is in topics)
- use a fork of action ssh-scp-ssh-pipelines which fails in case of error
- improve createrepo (manage concurrent commands)
- improve createrepo (manage concurrent commands)
- we are in python 3.8 now

### Bug Fixes

- fix title regex
- fix branch protection
- fix issue with latest 3.1 github provider
- fix wrong removal of directory .github for some repositories (#47)
- do not apply common files on github_organization_management


