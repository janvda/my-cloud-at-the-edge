
default: 
	@echo  "========================================================================================="
	@echo  ""
	@echo  "Supported make targets with description:"
	@echo  ""
	@echo  "  build   : build this (Mkdocs) documentation"
	@echo  "  serve   : run built-in dev-server that lets you preview this documentation"
	@echo  "  open    : open this documentation on built-in dev-server in browser"
	@echo  "  publish : deploy this documentation to GitHub Pages"
	@echo  "  open2   : open this documentation on GitHub Pages"
	@echo  "  help    : mkdocs help"		
	@echo  ""
	@echo  "E.g. If you want to publish the site enter command:"
	@echo  ""
	@echo  "   make publish"
	@echo  ""
	@echo  "========================================================================================="

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