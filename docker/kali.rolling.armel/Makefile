
container:
	@docker-compose build --pull --no-cache

kismet:
	@docker-compose run --rm -e NCORES kismet-build

kismet-release:
	@docker-compose run --rm -e CHECKOUT -e VERSION -e NCORES kismet-build

shell:
	@docker-compose run --rm kismet-build /bin/bash
