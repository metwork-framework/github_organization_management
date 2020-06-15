.PHONY: validate checks clean superclean

all: config.tf

checks:
	cat releases.json |json_verify
	cat labels.json |json_verify

config.tf: config.tf.jinja2
	cat $< |envtpl >$@ || (echo "ERROR during envtpl" ; rm -f $@ ; exit 1)

validate: checks config.tf .terraform/plugins/linux_amd64/lock.json
	terraform validate

clean:
	rm -f config.tf

apply: config.tf
	terraform apply

autoapply: config.tf
	terraform apply -auto-approve

superclean: clean
	rm -Rf .terraform terraform*

init: config.tf .terraform/plugins/linux_amd64/lock.json
	terraform init

.terraform/plugins/linux_amd64/lock.json:
	terraform init
