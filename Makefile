TAG?=latest

.PHONY: all
all: build

.PHONY: local
local:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o faas-netes

.PHONY: build-arm64
build-arm64:
	docker build -t openfaas/faas-netes:$(TAG)-arm64 . -f Dockerfile.arm64

.PHONY: build-armhf
build-armhf:
	docker build -t openfaas/faas-netes:$(TAG)-armhf . -f Dockerfile.armhf

.PHONY: build
build:
	docker build --build-arg http_proxy="${http_proxy}" --build-arg https_proxy="${https_proxy}" -t openfaas/faas-netes:$(TAG) .

.PHONY: push
push:
	docker push alexellis2/faas-netes:$(TAG)

.PHONY: namespaces
namespaces:
	kubectl apply -f namespaces.yml

.PHONY: install
install: namespaces
	kubectl apply -f yaml/

.PHONY: install-armhf
install-armhf: namespaces
	kubectl apply -f yaml_armhf/

.PHONY: charts
charts:
	cd chart && helm package openfaas/
	mv chart/*.tgz docs/
	helm repo index docs --url https://openfaas.github.io/faas-netes/ --merge ./docs/index.yaml

.PHONY: ci-armhf-build
ci-armhf-build:
	docker build -t openfaas/faas-netes:$(TAG)-armhf . -f Dockerfile.armhf

.PHONY: ci-armhf-push
ci-armhf-push:
	docker push openfaas/faas-netes:$(TAG)-armhf

.PHONY: ci-arm64-build
ci-arm64-build:
	docker build -t openfaas/faas-netes:$(TAG)-arm64 . -f Dockerfile.arm64

.PHONY: ci-arm64-push
ci-arm64-push:
	docker push openfaas/faas-netes:$(TAG)-arm64
