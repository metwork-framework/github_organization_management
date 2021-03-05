{%- if INTEGRATION_LEVEL|int >= 4 -%}
[![logo](https://raw.githubusercontent.com/metwork-framework/resources/master/logos/metwork-white-logo-small.png)](http://www.metwork-framework.org)
{% endif -%}
# {{REPO}}

[//]: # (automatically generated from https://github.com/metwork-framework/github_organization_management/blob/master/common_files/README.md)

**Status (master branch)**

{% set drone_managed = ("cat " + "REPO_HOME"|getenv + "/.drone.yml 2>/dev/null")|shell %}

{% if drone_managed != "" %}[![Drone CI](http://metwork-framework.org:8000/api/badges/metwork-framework/{{REPO}}/status.svg)](http://metwork-framework.org:8000/metwork-framework/{{REPO}}){% else %}[![GitHub CI](https://github.com/metwork-framework/{{REPO}}/workflows/CI/badge.svg?branch=master)](https://github.com/metwork-framework/{{REPO}}/actions?query=workflow%3ACI+branch%3Amaster){% endif %}
{%- if "docker-image" in "TOPICS"|getenv|from_json %}
[![DockerHub](https://github.com/metwork-framework/resources/blob/master/badges/dockerhub_link.svg)](https://hub.docker.com/r/metwork/{{REPO}}/)
{%- endif %}
{%- if INTEGRATION_LEVEL|int >= 1 %}
[![Maintenance](https://raw.githubusercontent.com/metwork-framework/resources/master/badges/maintained.svg)](https://github.com/metwork-framework/resources/blob/master/badges/maintained.svg)
{%- endif %}
{%- if INTEGRATION_LEVEL|int >= 5 %}
[![License](https://github.com/metwork-framework/resources/blob/master/badges/bsd.svg)]()
{%- endif %}
{%- if INTEGRATION_LEVEL|int >= 4 %}
[![Gitter](https://github.com/metwork-framework/resources/blob/master/badges/community-en.svg)](https://gitter.im/metwork-framework/community-en?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Gitter](https://github.com/metwork-framework/resources/blob/master/badges/community-fr.svg)](https://gitter.im/metwork-framework/community-fr?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
{%- endif %}
{{ ("cat " + "REPO_HOME"|getenv + "/.metwork-framework/EXTRA_BADGES.md 2>/dev/null")|shell }}

{% if INTEGRATION_LEVEL|int >= 4 %}
## What is MetWork FrameWork?

[MetWork Framework](https://metwork-framework.org) is an opensource system
for building and managing production grade applications or micro-services
(from development to operations).
{% endif %}

{{ ("cat " + "REPO_HOME"|getenv + "/.metwork-framework/README.md 2>/dev/null |envtpl")|shell }}

{% if INTEGRATION_LEVEL|int >= 5  or "mfextaddon_" in REPO %}
{% if "mfextaddon_" not in REPO %}

## Cheatsheet

A cheatsheet for this module is available [here](https://metwork-framework.org/pub/metwork/continuous_integration/docs/master/{{REPO}}/800-cheatsheet/)

{% endif %}

## Reference documentation

- (for **master (development)** version), see [this dedicated site](http://metwork-framework.org/pub/metwork/continuous_integration/docs/master/{{REPO}}/) for reference documentation.
- (for **latest released stable** version), see [this dedicated site](http://metwork-framework.org/pub/metwork/releases/docs/stable/{{REPO}}/) for reference documentation.

For very specific use cases, you might be interested in
[reference documentation for integration branch](http://metwork-framework.org/pub/metwork/continuous_integration/docs/integration/{{REPO}}/).

And if you are looking for an old released version, you can search [here](http://metwork-framework.org/pub/metwork/releases/docs/).

{% endif %}

{% if INTEGRATION_LEVEL|int >= 5  or "mfextaddon_" in REPO %}
## Installation guide

See [this document](https://metwork-framework.org/pub/metwork/continuous_integration/docs/master/{{REPO}}/100-installation_guide/).

{% if REPO != "mfext" %}
## Configuration guide

See [this document](https://metwork-framework.org/pub/metwork/continuous_integration/docs/master/{{REPO}}/300-configuration_guide/).
{% endif %}
{% endif %}

## Contributing guide

See [CONTRIBUTING.md](CONTRIBUTING.md) file.

{% if INTEGRATION_LEVEL|int >= 2 %}

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file.

{% endif %}

## Sponsors

*(If you are officially paid to work on MetWork Framework, please contact us to add your company logo here!)*

[![logo](https://raw.githubusercontent.com/metwork-framework/resources/master/sponsors/meteofrance-small.jpeg)](http://www.meteofrance.com)
