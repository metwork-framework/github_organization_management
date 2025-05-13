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
- add workflow for self-hosted repositories
- manage mfextaddons and their dispatches
- changes to manage both centos6 and centos8 builds
- update released changelogs in integration branch  (#58)
- build under centos8
- replace commit_message (deprecated) by commit_message_template
- add action remove_branch
- add action remove_branch_protection
- reactivate dependencies test on el8
- reactivate dependencies tests on el8
- remove python2 and references to drone
- switch from python 3.9 to python 3.10
- add langpacks-fr in image metwork/mfservplugins-centos8-buildimage
- upload rpms on nexus for private addons
- upgrade actions checkout and repository-dispatch (use NodeJS 16)
- remove deprecated set-output command
- mkdocs: superfences tabs is deprecated in favor of tabbed extension
- add release_2.1
- add initscripts and vim in build images
- add cronie (for crontab) in Metwork docker build images
- switch from python 3.10 to python 3.11
- fix image name on DockerHub
- trigger build of plugins rocky9 images
- fix repository links in installation guide
- add release 2.2
- add workflow_dispatch for buildimages repositories
- upgrade from Python 3.11 to Python 3.12
- authorize liblz4.so.1 as dependency
- authorize libmpi.so.12 and libhwloc.so.15 as dependencies
- authorize libcap.so.2 and libudev.so.1 (for fedora>=38)
- authorize mpîch dependencies for fedora>=39
- (revert) remove mpich dependencies on fedora >= 38
- add Qt5 libraries as authorized dependencies
- fix .gitignore and add authorized Qt5 dependency libraries
- authorized qt5 depedencies on rockylinux:9 and fedora's
- add revert_ldd_not_found.sh
- add libzip.so.5 and libssl.so.1.1
- add libXaw3d.so.8 (for gv)
- fix documentation builts with plugin awesome-nav
- authorize lttng-ust libraries and dependencies
- revert authorize lttng-ust libraries and dependencies
- add release_2.3
- add mfextaddon_extratools

### Bug Fixes

- fix title regex
- fix branch protection
- fix issue with latest 3.1 github provider
- fix wrong removal of directory .github for some repositories (#47)
- do not apply common files on github_organization_management
- fix usage with private repos
- automatic changelog must not fail if a repository is at integration-level-4 and has no released branch yet (#57)
- shellcheck fixes on test.sh
- fix badge CI in README file
- add libdav1d.so.7 as authorized dependency (for fedora >= 42)


