.PHONY: feedback-loop

.DEFAULT_GOAL = help

## Use stack to continuously rebuild/run the executable as the source changes
feedback-loop:
	@stack install :haskell-data-sink-demo --file-watch --exec='haskell-data-sink-demo'

## Run our web-service
run:
	@haskell-data-sink-demo

## Use docker to run redis
run-redis:
	@docker run --net=host -p 127.0.0.1:6379:6379 redis

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

## Use redis-cli to check the length of the enqueued table
enqueued-length:
	@docker exec -it mad_pike redis-cli LLEN enqueued

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
