install-deps:
	npm i
	cd scada.js; make install-deps CONF=../dcs-modules.txt

update-src:
	git pull
	git submodule update --recursive --init

touch-app-version:
	@(touch scada.js/lib/app-version.json)

release-build:
	(cd scada.js && make release)

release-push:
	(cd scada.js && make release-push)

release-pull: update-src
	(cd scada.js/release/main && git pull)

development:
	@(cd scada.js && make development)

