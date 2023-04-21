build:
	mkdocs build

serve:
	mkdocs serve

open:
	open http://127.0.0.1:8000/

publish:
	mkdocs gh-deploy --force

open2:
	open https://janvda.github.io/my-cloud-at-the-edge/

help:
	mkdocs -h