
REPO    ?= whisperos
BUILDER ?= docker

KUBE_VERSION=$(shell cat VERSION|grep KUBERNETES|sed -e 's/KUBERNETES[\ \t]*=[\ \t]*//' )
ETCD_VERSION=$(shell cat VERSION|grep ETCD|sed -e 's/ETCD[\ \t]*=[\ \t]*//')
KEEPALIVED_VERSION=$(shell cat VERSION|grep KEEPALIVED|sed -e 's/KEEPALIVED[\ \t]*=[\ \t]*//')
STRONGSWAN_VERSION=$(shell cat VERSION|grep STRONGSWAN|sed -e 's/STRONGSWAN[\ \t]*=[\ \t]*//')
FRR_VERSION=$(shell cat VERSION|grep FRR|sed -e 's/FRR[\ \t]*=[\ \t]*//')
HAPROXY_VERSION=$(shell cat VERSION|grep HAPROXY|sed -e 's/HAPROXY[\ \t]*=[\ \t]*//')
GOVERSION=$(shell cat VERSION|grep GO|sed -e 's/GO[\ \t]*=[\ \t]*//')
ALPINE_VERSION=$(shell cat VERSION|grep ALPINE|sed -e 's/ALPINE[\ \t]*=[\ \t]*//')
IPTABLES_VERSION=$(shell cat VERSION|grep IPTABLES|sed -e 's/IPTABLES[\ \t]*=[\ \t]*//')
HEKETI_VERSION=$(shell cat VERSION|grep HEKETI|sed -e 's/HEKETI[\ \t]*=[\ \t]*//')

.PHONY: version

all: kube etcd haproxy keepalived strongswan

version:
	@echo "Pushing to Repo    = $(REPO)"
	@echo
	@echo "Alpine Version     = $(ALPINE_VERSION)"
	@echo "Go Version         = $(GOVERSION)"
	@echo "Iptables Version   = $(IPTABLES_VERSION)"
	@echo "Kubernetes Version = $(KUBE_VERSION)"
	@echo "Etcd Version       = $(ETCD_VERSION)"
	@echo "Keepalived Version = $(KEEPALIVED_VERSION)"
	@echo "Haproxy Version    = $(HAPROXY_VERSION)"
	@echo "Strongswan Version = $(STRONGSWAN_VERSION)"
	@echo "Heketi Version     = $(HEKETI_VERSION)"
	$(shell sed -i -e '/##\ VERSIONS/,$$d' README.md )
	@echo "## VERSIONS" >> README.md
	@echo >> README.md
	@echo "  - Kubernetes: $(KUBE_VERSION)" >> README.md
	@echo "  - Etcd:       $(ETCD_VERSION)" >> README.md
	@echo "  - Keepalived: $(KEEPALIVED_VERSION)" >> README.md
	@echo "  - Haproxy:    $(HAPROXY_VERSION)" >> README.md
	@echo "  - Heketi:     $(HEKETI_VERSION)" >> README.md
	@echo "  - Strongswan: $(STRONGSWAN_VERSION)" >> README.md
	@echo "  - IPtables:   $(IPTABLES_VERSION)" >> README.md
	@echo "  - Alpine:     $(ALPINE_VERSION)" >> README.md
	@echo "  - Go:         $(GOVERSION)" >> README.md

kube: kube-build kube-push
etcd: etcd-build etcd-push
haproxy: haproxy-build haproxy-push
keepalived: keepalived-build keepalived-push
strongswan: strongswan-build strongswan-push

auto-strongswan:
	git checkout -b strongswan-$(STRONGSWAN_VERSION)
	@sed -e s/@VERSION@/$(STRONGSWAN_VERSION)/g \
		 -e s/@IPTABLES_VERSION@/$(IPTABLES_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.strongswan.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy Strongswan $(STRONGSWAN_VERSION)"
	git push origin strongswan-$(STRONGSWAN_VERSION)
	git checkout master

auto-heketi:
	git checkout -b heketi-$(HEKETI_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(HEKETI_VERSION)/g \
		 -e s/@GOVERSION@/$(GOVERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		Dockerfile.heketi.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy Heketi $(HEKETI_VERSION)"
	git push origin heketi-$(HEKETI_VERSION)
	git checkout master

auto-kube-builder:
	git checkout -b kube-builder-$(KUBE_VERSION)
	@sed -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@GOVERSION@/$(GOVERSION)/g \
		Dockerfile.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy Kube-Builder $(KUBE_VERSION)"
	git push origin kube-builder-$(KUBE_VERSION)
	git checkout master
auto-kube-apiserver:
	git checkout -b kube-apiserver-$(KUBE_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		Dockerfile.kube-apiserver.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy Kube-Apiserver $(KUBE_VERSION)"
	git push origin kube-apiserver-$(KUBE_VERSION)
	git checkout master
auto-kube-scheduler:
	git checkout -b kube-scheduler-$(KUBE_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.kube-scheduler.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy kube-scheduler $(KUBE_VERSION)"
	git push origin kube-scheduler-$(KUBE_VERSION)
	git checkout master
auto-kube-controller-manager:
	git checkout -b kube-controller-manager-$(KUBE_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.kube-controller-manager.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy kube-controller-manager $(KUBE_VERSION)"
	git push origin kube-controller-manager-$(KUBE_VERSION)
	git checkout master
auto-kube-proxy:
	git checkout -b kube-proxy-$(KUBE_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@IPTABLES_VERSION@/$(IPTABLES_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.kube-proxy.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy kube-proxy $(KUBE_VERSION)"
	git push origin kube-proxy-$(KUBE_VERSION)
	git checkout master
auto-kubelet:
	git checkout -b kubelet-$(KUBE_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@IPTABLES_VERSION@/$(IPTABLES_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.kubelet.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy kubelet $(KUBE_VERSION)"
	git push origin kubelet-$(KUBE_VERSION)
	git checkout master

auto-etcd-builder:
	git checkout -b etcd-builder-$(ETCD_VERSION)
	@sed -e s/@VERSION@/$(ETCD_VERSION)/g \
		 -e s/@GOVERSION@/$(GOVERSION)/g \
		Dockerfile.etcd-builder.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy ETCD-Builder $(ETCD_VERSION)"
	git push origin etcd-builder-$(ETCD_VERSION)
	git checkout master
auto-etcd:
	git checkout -b etcd-$(ETCD_VERSION)
	@sed -e s/@REPO@/$(REPO)/g \
		 -e s/@VERSION@/$(VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.etcd.in  > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy ETCD $(ETCD_VERSION)"
	git push origin etcd-$(ETCD_VERSION)
	git checkout master

auto-haproxy:
	git checkout -b haproxy-$(HAPROXY_VERSION)
	@sed -e s/@VERSION@/$(HAPROXY_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.haproxy.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy Haproxy $(HAPROXY_VERSION)"
	git push origin haproxy-$(HAPROXY_VERSION)
	git checkout master

auto-keepalived:
	git checkout -b keepalived-$(KEEPALIVED_VERSION)
	@sed -e s/@VERSION@/$(KEEPALIVED_VERSION)/g \
		 -e s/@IPTABLES_VERSION@/$(IPTABLES_VERSION)/g \
		 -e s/@ALPINE_VERSION@/$(ALPINE_VERSION)/g \
		 Dockerfile.keepalived.in > Dockerfile
	git add -f Dockerfile
	git commit Dockerfile -m "Auto-deploy Keepalived $(KEEPALIVED_VERSION)"
	git push origin keepalived-$(KEEPALIVED_VERSION)
	git checkout master

strongswan-build:
	@sed -e s/@VERSION@/$(STRONGSWAN_VERSION)/g Dockerfile.strongswan.in > Dockerfile.strongswan
	$(BUILDER) build -f Dockerfile.strongswan -t $(REPO)/strongswan:$(STRONGSWAN_VERSION) .

keepalived-build:
	@sed -e s/@VERSION@/$(KEEPALIVED_VERSION)/g Dockerfile.keepalived.in > Dockerfile.keepalived
	$(BUILDER) build -f Dockerfile.keepalived -t $(REPO)/keepalived:$(KEEPALIVED_VERSION) .

haproxy-build:
	@sed -e s/@VERSION@/$(HAPROXY_VERSION)/g Dockerfile.haproxy.in > Dockerfile.haproxy
	$(BUILDER) build -f Dockerfile.haproxy -t $(REPO)/haproxy:$(HAPROXY_VERSION) .

etcd-build:
	@sed -e s/@VERSION@/$(ETCD_VERSION)/g \
		 -e s/@GOVERSION@/$(GOVERSION)/g \
		Dockerfile.etcd-builder.in > Dockerfile.etcd-builder
	@sed -e s/@REPO@/$(REPO)/g Dockerfile.etcd.in  > Dockerfile.etcd
	$(BUILDER) build -f Dockerfile.etcd-builder -t $(REPO)/etcd-builder:latest .
	$(BUILDER) build -f Dockerfile.etcd -t $(REPO)/etcd:$(ETCD_VERSION) .

kube-build:
	@sed -e s/@VERSION@/$(KUBE_VERSION)/g \
		 -e s/@GOVERSION@/$(GOVERSION)/g \
		Dockerfile.in > Dockerfile
	$(BUILDER) build -f Dockerfile -t $(REPO)/kube-builder:latest .
	@sed -e s/@REPO@/$(REPO)/g Dockerfile.kube-controller-manager.in > Dockerfile.kube-controller-manager
	@sed -e s/@REPO@/$(REPO)/g          Dockerfile.kube-scheduler.in > Dockerfile.kube-scheduler
	@sed -e s/@REPO@/$(REPO)/g          Dockerfile.kube-apiserver.in > Dockerfile.kube-apiserver
	@sed -e s/@REPO@/$(REPO)/g -e s/@IPTABLES_VERSION@/$(IPTABLES_VERSION)/g Dockerfile.kube-proxy.in > Dockerfile.kube-proxy
	$(BUILDER) build -f Dockerfile.kube-controller-manager -t $(REPO)/kube-controller-manager:$(KUBE_VERSION) .
	$(BUILDER) build -f Dockerfile.kube-apiserver -t $(REPO)/kube-apiserver:$(KUBE_VERSION) .
	$(BUILDER) build -f Dockerfile.kube-scheduler -t $(REPO)/kube-scheduler:$(KUBE_VERSION) .
	$(BUILDER) build -f Dockerfile.kube-proxy -t $(REPO)/kube-proxy:$(KUBE_VERSION) .

kube-proxy:
	@sed -e s/@REPO@/$(REPO)/g -e s/@IPTABLES_VERSION@/$(IPTABLES_VERSION)/g Dockerfile.kube-proxy.in > Dockerfile.kube-proxy
	$(BUILDER) build -f Dockerfile.kube-proxy -t $(REPO)/kube-proxy:$(KUBE_VERSION) .

haproxy-push:
	$(BUILDER) push $(REPO)/haproxy:$(HAPROXY_VERSION)
	$(BUILDER) tag  $(REPO)/haproxy:$(HAPROXY_VERSION) $(REPO)/haproxy:latest
	$(BUILDER) push $(REPO)/haproxy:latest

keepalived-push:
	$(BUILDER) push $(REPO)/keepalived:$(KEEPALIVED_VERSION)
	$(BUILDER) tag  $(REPO)/keepalived:$(KEEPALIVED_VERSION) $(REPO)/keepalived:latest
	$(BUILDER) push $(REPO)/keepalived:latest

strongswan-push:
	$(BUILDER) push $(REPO)/strongswan:$(STRONGSWAN_VERSION)
	$(BUILDER) tag  $(REPO)/strongswan:$(STRONGSWAN_VERSION) $(REPO)/strongswan:latest
	$(BUILDER) push $(REPO)/strongswan:latest

etcd-push:
	$(BUILDER) push $(REPO)/etcd:$(ETCD_VERSION)
	$(BUILDER) tag  $(REPO)/etcd:$(ETCD_VERSION) $(REPO)/etcd:latest
	$(BUILDER) push $(REPO)/etcd:latest

kube-push:
	$(BUILDER) push $(REPO)/kube-apiserver:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-apiserver:$(KUBE_VERSION) $(REPO)/kube-apiserver:latest
	$(BUILDER) push $(REPO)/kube-apiserver:latest
	$(BUILDER) push $(REPO)/kube-scheduler:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-scheduler:$(KUBE_VERSION) $(REPO)/kube-scheduler:latest
	$(BUILDER) push $(REPO)/kube-scheduler:latest
	$(BUILDER) push $(REPO)/kube-proxy:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-proxy:$(KUBE_VERSION) $(REPO)/kube-proxy:latest
	$(BUILDER) push $(REPO)/kube-proxy:latest
	$(BUILDER) push $(REPO)/kube-controller-manager:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-controller-manager:$(KUBE_VERSION) $(REPO)/kube-controller-manager:latest
	$(BUILDER) push $(REPO)/kube-controller-manager:latest
