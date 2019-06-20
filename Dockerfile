FROM golang:1.12.6 AS builder

RUN mkdir -p /build

RUN cd $GOPATH  && apt-get update && apt-get install rsync -y \
	&& mkdir -p src/k8s.io/kubernetes \
	&& cd src/k8s.io/kubernetes \
	&& curl -L https://github.com/kubernetes/kubernetes/archive/v1.15.0.tar.gz | tar xz --strip-components=1 -C .

RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& sed -i -e "/vendor\/github.com\/jteeuwen\/go-bindata\/go-bindata/d" hack/lib/golang.sh \
	&& sed -i -e "/export PATH/d" hack/generate-bindata.sh

RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-controller-manager GOFLAGS=-v
RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-apiserver GOFLAGS=-v
RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-scheduler GOFLAGS=-v
RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-proxy GOFLAGS=-v
RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kubelet GOFLAGS=-v

RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& cp _output/bin/kube-controller-manager /build \
	&& cp _output/bin/kube-apiserver /build \
	&& cp _output/bin/kube-scheduler /build \
	&& cp _output/bin/kube-proxy /build \
	&& cp _output/bin/kubelet /build \
	&& strip /build/kube-apiserver \
	&& strip /build/kube-scheduler \
	&& strip /build/kube-controller-manager \
	&& strip /build/kube-proxy \
	&& strip /build/kubelet

FROM scratch
COPY --from=builder /build/kube-apiserver /
COPY --from=builder /build/kube-proxy /
COPY --from=builder /build/kube-controller-manager /
COPY --from=builder /build/kube-scheduler /
COPY --from=builder /build/kubelet /
