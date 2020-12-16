.PHONY: validate checks clean apply

validate: repositories.json
	cat releases.json |json_verify
	cat labels.json |json_verify
	cat repositories.json |json_verify

repositories.json:
	bin/get_repos.py metwork-framework >$@ || (echo "ERROR during get_repos.py" ; rm -f $@ ; exit 1)

clean:
	rm -f repositories.json

debug_common_files:
	export DEBUG=2 ; bin/apply_common_files.sh

debug_common_mergify:
	export DEBUG=2 ; bin/apply_common_mergify.sh

apply:
	bin/set_config.py
