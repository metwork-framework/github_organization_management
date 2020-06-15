.PHONY: validate checks clean superclean

all: config.tf

checks:
	cat releases.json |json_verify
	cat labels.json |json_verify

config.tf: config.tf.jinja2
	cat $< |envtpl >$@ || (echo "ERROR during envtpl" ; rm -f $@ ; exit 1)

validate: checks config.tf
	terraform validate

clean:
	rm -f config.tf

apply: checks config.tf
	terraform apply

superclean: clean
	rm -Rf .terraform terraform*
