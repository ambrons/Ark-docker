DOCKER_BUILD_NAME=build-system-config

.PHONY: all clean deps gotpl

all: ignition.json

GOTPL := $(shell go env GOPATH)/bin/gotpl
CT := $(shell pwd)/build/config-transpiler/bin/ct

build:
	mkdir build

$(CT): build
	git clone --branch v0.3.1 \
	  https://github.com/coreos/container-linux-config-transpiler \
	  build/config-transpiler
	cd build/config-transpiler; ./build

$(GOTPL):
	go get github.com/tsg/gotpl

container-linux.yaml: $(GOTPL) container-linux.tmpl.yaml
	$(GOTPL) container-linux.tmpl.yaml < params.yaml > container-linux.yaml

ignition.json: $(CT) container-linux.yaml
	$(CT) < container-linux.yaml > ignition.json

clean:
	rm -fr ignition.json container-linux.yaml build/
