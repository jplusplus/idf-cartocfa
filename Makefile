run:
	grunt serve

build:
	grunt

install:
	npm install
	./node_modules/.bin/bower install
	grunt bowerInstall

staging: build
	rsync --delete -ravz -e ssh ./dist/ jacob.jplusplus.org:/home/pirhoo/public_html/idf-cartocfa
