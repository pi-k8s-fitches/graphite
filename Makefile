MACHINE=$(shell uname -m)
IMAGE=pi-k8s-fitches-graphite
VERSION=0.1
TAG="$(VERSION)-$(MACHINE)"
ACCOUNT=gaf3
NAMESPACE=fitches
PORT=7070
VOLUMES=-v ${PWD}/storage:/opt/graphite/storage -v ${PWD}/log:/var/log -v ${PWD}/redis:/var/lib/redis

ifeq ($(MACHINE),armv7l)
BASE=arm32v6/alpine:3.8
else
BASE=alpine:3.8
endif

.PHONY: build shell start stop push create update delete create-dev update-dev delete-dev

build:
	docker build . --build-arg BASE=$(BASE) -t $(ACCOUNT)/$(IMAGE):$(TAG)

shell:
	docker run -it $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(TAG) sh

start:
	docker run --name $(IMAGE)-$(VERSION) $(VARIABLES) $(VOLUMES) -d --rm -p 127.0.0.1:$(PORT):80 -p 127.0.0.1:2003:2003 -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(TAG)

stop:
	docker rm -f $(IMAGE)-$(VERSION)

push: build
	docker push $(ACCOUNT)/$(IMAGE):$(TAG)

create:
	kubectl --context=pi-k8s create -f k8s/pi-k8s.yaml

update:
	kubectl --context=pi-k8s replace -f k8s/pi-k8s.yaml

delete:
	kubectl --context=pi-k8s delete -f k8s/pi-k8s.yaml

create-dev:
	kubectl --context=minikube create -f k8s/minikube.yaml

update-dev:
	kubectl --context=minikube replace -f k8s/minikube.yaml

delete-dev:
	kubectl --context=minikube delete -f k8s/minikube.yaml
