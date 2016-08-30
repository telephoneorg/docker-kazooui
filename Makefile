NS = vp
NAME = kazooui
APP_VERSION = 3.22
IMAGE_VERSION = 2.0
VERSION = $(APP_VERSION)-$(IMAGE_VERSION)
LOCAL_TAG = $(NS)/$(NAME):$(VERSION)

REGISTRY = callforamerica
ORG = vp
REMOTE_TAG = $(REGISTRY)/$(NAME):$(VERSION)

GITHUB_REPO = docker-kazooui
DOCKER_REPO = kazooui
BUILD_BRANCH = master


.PHONY: all build test release shell run start stop rm rmi default

all: build

checkout:
	@git checkout $(BUILD_BRANCH)

build:
	@docker build -t $(LOCAL_TAG) --rm .
	$(MAKE) tag

tag:
	@docker tag $(LOCAL_TAG) $(REMOTE_TAG)

rebuild:
	@docker build -t $(LOCAL_TAG) --rm --no-cache .

test:
	@rspec ./tests/*.rb

commit:
	@git add -A .
	@git commit

deploy:
	@docker push $(REMOTE_TAG)

push:
	@git push origin master

shell:
	@docker exec -ti $(NAME) /bin/bash

run:
	@docker run -it --rm --name $(NAME) --entrypoint bash $(LOCAL_TAG)

launch:
	@docker run -d --name $(NAME) -h kazooui -p "80:80" --cap-add NET_ADMIN $(LOCAL_TAG)

launch-net:
	@docker run -d --name $(NAME) -h kazooui --network=local --net-alias kazooui $(LOCAL_TAG)

create-network:
	@docker network create -d bridge local

logs:
	@docker logs $(NAME)

logsf:
	@docker logs -f $(NAME)

start:
	@docker start $(NAME)

kill:
	@docker kill $(NAME)

stop:
	@docker stop $(NAME)

rm:
	@docker rm $(NAME)

rmi:
	@docker rmi $(LOCAL_TAG)
	@docker rmi $(REMOTE_TAG)

kube-deploy:
	@kubectl create -f kubernetes/$(NAME)-deployment.yaml --record

kube-deploy-edit:
	@kubectl edit deployment/$(NAME)
	$(MAKE) kube-rollout-status

kube-deploy-rollback:
	@kubectl rollout undo deployment/$(NAME)

kube-rollout-status:
	@kubectl rollout status deployment/$(NAME)

kube-rollout-history:
	@kubectl rollout history deployment/$(NAME)

kube-delete-deployment:
	@kubectl delete deployment/$(NAME)

kube-deploy-service:
	@kubectl create -f kubernetes/$(NAME)-service.yaml

kube-delete-service:
	@kubectl delete svc $(NAME)

kube-replace-service:
	@kubectl replace -f kubernetes/$(NAME)-service.yaml

default: build