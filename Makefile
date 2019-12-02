NAME       := acme
TAG        := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: build push clean

build:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

push:
	docker push $(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG)
