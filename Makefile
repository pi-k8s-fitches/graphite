MACHINE=$(shell uname -m)
IMAGE=pi-k8s-fitches-graphite
VERSION=0.1
TAG="$(VERSION)-$(MACHINE)"
ACCOUNT=gaf3
NAMESPACE=fitches
PORT=7070
VOLUMES=-v ${PWD}/storage:/opt/graphite/storage -v ${PWD}/redis:/var/lib/redis -v ${PWD}/log:/var/log

ifeq ($(MACHINE),armv7l)
BASE=arm32v6/alpine:3.8
else
BASE=alpine:3.8
endif

.PHONY: build dirs shell start stop push volumes create update delete volumes-dev create-dev update-dev delete-dev

build:
	docker build . --build-arg BASE=$(BASE) -t $(ACCOUNT)/$(IMAGE):$(TAG)

dirs:
	mkdir -p storage
	mkdir -p redis
	mkdir -p log
	chmod a+w storage
	chmod a+w redis
	chmod a+w log

shell:
	docker run -it $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(TAG) sh

start:
	docker run --name $(IMAGE)-$(VERSION) -d --rm -p 127.0.0.1:$(PORT):80 -p 127.0.0.1:2003:2003 -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(TAG)

stop:
	docker rm -f $(IMAGE)-$(VERSION)

push: build
	docker push $(ACCOUNT)/$(IMAGE):$(TAG)

volumes:
	sudo mkdir -p /var/lib/pi-k8s/graphite/storage
	sudo mkdir -p /var/lib/pi-k8s/graphite/redis
	sudo mkdir -p /var/lib/pi-k8s/graphite/log
	sudo chmod a+w /var/lib/pi-k8s/graphite/storage
	sudo chmod a+w /var/lib/pi-k8s/graphite/redis
	sudo chmod a+w /var/lib/pi-k8s/graphite/log

create:
	kubectl --context=pi-k8s create -f k8s/pi-k8s.yaml

delete:
	kubectl --context=pi-k8s delete -f k8s/pi-k8s.yaml

update: delete create

volumes-dev: volumes

create-dev:
	kubectl --context=minikube create -f k8s/minikube.yaml

delete-dev:
	kubectl --context=minikube delete -f k8s/minikube.yaml

update-dev: delete-dev create-dev
