.PHONY: validate checks clean superclean

all: config.tf

checks: repositories.json
	cat releases.json |json_verify
	cat labels.json |json_verify
	cat repositories.json |json_verify

config.tf: config.tf.jinja2 repositories.json
	cat $< |envtpl >$@ || (echo "ERROR during envtpl" ; rm -f $@ ; exit 1)

repositories.json:
	bin/get_repos.py metwork-framework >$@ || (echo "ERROR during get_repos.py" ; rm -f $@ ; exit 1)

validate: checks config.tf .terraform/plugins/linux_amd64/lock.json
	terraform validate

clean:
	rm -f config.tf repositories.json

apply: config.tf
	terraform apply

autoapply: config.tf
	terraform apply -auto-approve

autoapply_norefresh: config.tf
	terraform apply -auto-approve -refresh=false

superclean: clean
	rm -Rf .terraform terraform*

init: config.tf .terraform/plugins/linux_amd64/lock.json
	terraform init

.terraform/plugins/linux_amd64/lock.json:
	terraform init
