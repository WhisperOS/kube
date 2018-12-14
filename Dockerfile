FROM whisperos/etcd-builder:latest AS builder

FROM alpine:3.8

RUN apk upgrade --update --no-cache \
	&& addgroup -S -g 159 etcd \
	&& adduser  -S -g 159 -u 159 -G etcd etcd

USER etcd

COPY --from=builder /build/etcd /
