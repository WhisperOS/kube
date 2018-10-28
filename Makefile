
REPO ?= graytshirt

KUBE_VERSION=$(shell cat VERSION|grep KUBERNETES|sed -e 's/KUBERNETES[\ \t]*=[\ \t]*//' )
ETCD_VERSION=$(shell cat VERSION|grep ETCD|sed -e 's/ETCD[\ \t]*=[\ \t]*//')
KEEPALIVED_VERSION=$(shell cat VERSION|grep KEEPALIVED|sed -e 's/KEEPALIVED[\ \t]*=[\ \t]*//')
HAPROXY_VERSION=$(shell cat VERSION|grep HAPROXY|sed -e 's/HAPROXY[\ \t]*=[\ \t]*//')

.PHONY: version

all: kube etcd haproxy keepalived

version:
	@echo "Pushing to Repo    = $(REPO)"
	@echo
	@echo "Kubernetes Version = $(KUBE_VERSION)"
	@echo "Etcd Version       = $(ETCD_VERSION)"
	@echo "Keepalived Version = $(KEEPALIVED_VERSION)"
	@echo "Haproxy Version    = $(HAPROXY_VERSION)"
	$(shell sed -i '' -e '/##\ VERSIONS/,$$d' README.md )
	@echo "## VERSIONS" >> README.md
	@echo >> README.md
	@echo "  - Kubernetes: $(KUBE_VERSION)" >> README.md
	@echo "  - Etcd:       $(ETCD_VERSION)" >> README.md
	@echo "  - Keepalived: $(KEEPALIVED_VERSION)" >> README.md
	@echo "  - Haproxy:    $(HAPROXY_VERSION)" >> README.md

kube: kube-build kube-push
etcd: etcd-build etcd-push
haproxy: haproxy-build haproxy-push
keepalived: keepalived-build keepalived-push

keepalived-build:
	@sed -e s/@VERSION@/$(KEEPALIVED_VERSION)/ Dockerfile.keepalived.in > Dockerfile.keepalived
	docker build . -f Dockerfile.keepalived -t $(REPO)/keepalived:$(KEEPALIVED_VERSION)

haproxy-build:
	@sed -e s/@VERSION@/$(HAPROXY_VERSION)/ Dockerfile.haproxy.in > Dockerfile.haproxy
	docker build . -f Dockerfile.haproxy -t $(REPO)/haproxy:$(HAPROXY_VERSION)

etcd-build:
	@sed -e s/@VERSION@/$(ETCD_VERSION)/ Dockerfile.etcd-builder.in > Dockerfile.etcd-builder
	docker build . -f Dockerfile.etcd-builder -t $(REPO)/etcd-builder:latest
	docker build . -f Dockerfile.etcd -t $(REPO)/etcd:$(ETCD_VERSION)

kube-build:
	@sed -e s/@VERSION@/$(KUBE_VERSION)/ Dockerfile.in > Dockerfile
	docker build . -t $(REPO)/kubernetes-builder:latest
	docker build -f Dockerfile.kube-controller-manager -t $(REPO)/kube-controller-manager:$(KUBE_VERSION) .
	docker build -f Dockerfile.kube-apiserver -t $(REPO)/kube-apiserver:$(KUBE_VERSION) .
	docker build -f Dockerfile.kube-scheduler -t $(REPO)/kube-scheduler:$(KUBE_VERSION) .
	docker build -f Dockerfile.kube-proxy -t $(REPO)/kube-proxy:$(KUBE_VERSION) .

haproxy-push:
	docker push $(REPO)/haproxy:$(HAPROXY_VERSION)
	docker tag  $(REPO)/haproxy:$(HAPROXY_VERSION) $(REPO)/haproxy:latest
	docker push $(REPO)/haproxy:latest

keepalived-push:
	docker push $(REPO)/keepalived:$(KEEPALIVED_VERSION)
	docker tag  $(REPO)/keepalived:$(KEEPALIVED_VERSION) $(REPO)/keepalived:latest
	docker push $(REPO)/keepalived:latest

etcd-push:
	docker push $(REPO)/etcd:$(ETCD_VERSION)
	docker tag  $(REPO)/etcd:$(ETCD_VERSION) $(REPO)/etcd:latest
	docker push $(REPO)/etcd:latest

kube-push:
	docker push $(REPO)/kube-apiserver:$(KUBE_VERSION)
	docker tag  $(REPO)/kube-apiserver:$(KUBE_VERSION) $(REPO)/kube-apiserver:latest
	docker push $(REPO)/kube-apiserver:latest
	docker push $(REPO)/kube-scheduler:$(KUBE_VERSION)
	docker tag  $(REPO)/kube-scheduler:$(KUBE_VERSION) $(REPO)/kube-scheduler:latest
	docker push $(REPO)/kube-scheduler:latest
	docker push $(REPO)/kube-proxy:$(KUBE_VERSION)
	docker tag  $(REPO)/kube-proxy:$(KUBE_VERSION) $(REPO)/kube-proxy:latest
	docker push $(REPO)/kube-proxy:latest
	docker push $(REPO)/kube-controller-manager:$(KUBE_VERSION)
	docker tag  $(REPO)/kube-controller-manager:$(KUBE_VERSION) $(REPO)/kube-controller-manager:latest
	docker push $(REPO)/kube-controller-manager:latest
