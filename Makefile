export GO111MODULE=on

GOPATH:=$(shell go env GOPATH)
VERSION=$(shell git describe --tags --always)
INTERNAL_PROTO_FILES=$(shell find proto -name *.proto)
API_PROTO_FILES=$(shell find proto -name *.proto)

.PHONY: init
init:
	go get -v google.golang.org/protobuf/cmd/protoc-gen-go
	go get -v google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go get -v github.com/envoyproxy/protoc-gen-validate
	go mod tidy

.PHONY: errors
# generate errors code
errors:
	protoc --proto_path=. \
               --proto_path=./third_party \
               --go_out=paths=source_relative:. \
               --go-errors_out=paths=source_relative:. \
               $(API_PROTO_FILES)

.PHONY: proto
# generate internal proto
proto:
	protoc --proto_path=. \
	       --proto_path=./third_party \
 	       --go_out=paths=source_relative:. \
				 --go-errors_out=paths=source_relative:. \
	       $(INTERNAL_PROTO_FILES)

.PHONY: all
# generate all
all: errors
	go generate ./...
	go mod tidy
	go mod download

# show help
help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
