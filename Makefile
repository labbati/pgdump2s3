VERSION := 0.1.0

build:
	docker build -t labbati/pgdump2s3:${VERSION} .

publish: build
	echo "About to publish"

run: build
	docker run --rm labbati/pgdump2s3:${VERSION}

shell: build
	docker run --rm -ti labbati/pgdump2s3:${VERSION} sh

.PONY: build publish run shell
