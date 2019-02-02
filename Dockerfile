FROM golang:1.11.5

RUN mkdir -p /build

RUN cd $GOPATH \
	&& mkdir -p src/github.com/etcd-io/etcd \
	&& cd src/github.com/etcd-io/etcd \
	&& curl -L https://github.com/etcd-io/etcd/archive/v3.3.11.tar.gz | tar xz --strip-components=1 -C .

RUN cd $GOPATH/src/github.com/etcd-io/etcd \
	&& sed -e 's|GIT_SHA=.*|GIT_SHA=v3.3.11|' -i build \
	&& ./build

RUN cd $GOPATH/src/github.com/etcd-io/etcd \
	&& cp bin/etcd    /build \
	&& cp bin/etcdctl /build \
	&& strip /build/etcd \
	&& strip /build/etcdctl
