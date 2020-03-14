help:
	@echo "Usage:"
	@echo "  make build\n    build an image 'labbati/pgdump2s3:debug' for local testing and debugging."
	@echo "  make shell\n    build an image 'labbati/pgdump2s3:debug' and open a sh shell into it."
	@echo "  make VERSION=\"1.2.3\" release\n    tag an image and push it to trigger the build on docker hub."

build:
	@docker build -t labbati/pgdump2s3:debug .

shell: build
	@docker run --rm -ti labbati/pgdump2s3:debug sh

release:
	@git tag v${VERSION}
	@git push --tag origin v${VERSION}
	@echo "Released version v${VERSION}. It will take a few minutes before it is available on docker hub"

.PONY: help build shell release
