run:
	grunt serve

build:
	grunt

install:
	npm install
	bower install
	grunt bowerInstall

staging: build
	scp -r ./dist/ jacob.jplusplus.org:/home/pirhoo/public_html/idf-cartocfa
