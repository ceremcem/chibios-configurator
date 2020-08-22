install-deps:
	npm i
	cd scada.js; make install-deps CONF=../dcs-modules.txt

update-app:
	git pull
	git submodule update --recursive --init

touch-app-version:
	@(touch scada.js/lib/app-version.json)

release-build:
	(cd scada.js && make production)

release-push:
	(cd scada.js && make release-push)

development:
	@(cd scada.js && make development)

