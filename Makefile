build:
	docker build -t labbati/pgdump2s3:debug .

run: build
	docker run --rm labbati/pgdump2s3:debug

shell: build
	docker run --rm -ti labbati/pgdump2s3:debug sh

.PONY: build run shell
