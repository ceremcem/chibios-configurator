install-deps:
	npm i
	cd scada.js; make install-deps CONF=../dcs-modules.txt

main-dev:
	cd scada.js && make development APP=main

main-production:
	cd scada.js && make production APP=main

update:
	git pull
	git submodule update --recursive --init

touch-app-version:
	@(touch scada.js/lib/app-version.json)

release:
	(cd scada.js && make production)

development:
	@(cd scada.js && make development)
