.PHONY: feedback-loop

.DEFAULT_GOAL = help

## Install libpq-dev
install-libpq:
	@sudo apt-get install libpq-dev

## Use stack to continuously rebuild/run the demo web service
feedback-loop:
	@stack install :demo-sink :demo-web-service --file-watch --exec='./run-demo.sh'

## Run our web-service
run-web-service:
	@demo-web-service

## Run our demo data processing sink
run-sink:
	@demo-sink

## Use docker to run redis
run-redis:
	@docker run --rm --name=redis --net=host -p 127.0.0.1:6379:6379 redis:alpine

## Use docker to run postgres
run-postgres:
	@docker run --rm --name=postgres --net=host -v ${PWD}/pg-data:/var/lib/postgresql -p 127.0.0.1:5432:5432 -e POSTGRES_PASSWORD=password postgres:alpine

## Use docker exec and psql to create a database in the db container
create-test-db:
	@docker exec -it postgres /bin/bash -c "psql -U postgres -c 'CREATE DATABASE test;'"

## Use curl to send JSON POST to test
post-msg:
	@echo "curl status:"
	@curl localhost:2378/status
	@echo "\n\nempty curl, response:"
	@curl localhost:2378
	@echo "\n\ninvalid JSON, response:"
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": "username":"xyz","password":"xyz"}' localhost:2378
	@echo "\n\nvalid JSON, response:"
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378

## Use curl to send lots of JSON POST to test
load-test:
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	@curl -i -H "Content-Type: application/json" -X POST -d '{"id": 1, "username":"xyz","password":"xyz"}' localhost:2378
	
## Use redis-cli to check the length of the enqueued table
enqueued-length:
	@docker exec -it redis redis-cli LLEN enqueued

## Use redis-cli to check the length of the processing table
processing-length:
	@docker exec -it redis redis-cli LLEN processing


## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
