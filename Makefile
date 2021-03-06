.PHONY: up
up:
	./generate-sentry-secret-key.sh
	docker-compose up -d redis postgres
	docker-compose -f docker-compose-tools.yml run --rm wait_postgres
	docker-compose -f docker-compose-tools.yml run --rm wait_redis
	# There is "pip uninstall sentry-plugins" here to fix this bug https://github.com/getsentry/sentry/issues/11302
	docker-compose run --rm sentry bash -c "pip uninstall sentry-plugins -y; sentry upgrade --noinput"
	docker-compose run --rm sentry sentry createuser \
		--email admin@example.com \
		--password password \
		--superuser --no-input
	docker-compose up -d
	@echo "Open your browser at http://`docker-compose port sentry 9000` (login, password: admin@example.com / password)"

.PHONY: clean
clean:
	docker-compose down -v --remove-orphans
	rm -rf postgresql-data/