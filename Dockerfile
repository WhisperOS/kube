FROM golang:1.12.5 AS builder

RUN mkdir -p /build

RUN cd $GOPATH  && apt-get update && apt-get install rsync -y \
	&& mkdir -p src/github.com/heketi/heketi \
	&& cd src/github.com/heketi/heketi \
	&& curl -L https://github.com/heketi/heketi/archive/v9.0.0.tar.gz | tar xz --strip-components=1 -C . \
	&& mkdir vendor \
	&& curl -L https://github.com/heketi/heketi/releases/download/v9.0.0/heketi-deps-v9.0.0.tar.gz | tar xz --strip-components=1 -C vendor

RUN cd $GOPATH/src/github.com/heketi/heketi \
	&& CGO_ENABLED=0 GOOS=linux GOARCH=amd64  go build -v -ldflags "-X main.HEKETI_VERSION=9.0.0-kubes -w -extldflags '-static -z relro -z now'" -o heketi \
	&& cd client/cli/go \
	&& CGO_ENABLED=0 GOOS=linux GOARCH=amd64  go build -v -ldflags "-X main.HEKETI_VERSION=9.0.0-kubes -w -extldflags '-static -z relro -z now'" -o heketi-cli

RUN cd $GOPATH/src/github.com/heketi/heketi \
	&& cp client/cli/go/heketi-cli /build \
	&& cp heketi /build \
	&& strip /build/heketi \
	&& strip /build/heketi-cli

FROM alpine:3.9.4
COPY --from=builder /build/heketi /
COPY --from=builder /build/heketi-cli /
RUN mkdir /root/.ssh && echo -e "Host *\n  StrictHostKeyChecking no" > /root/.ssh/config
