FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.8

RUN apk upgrade --update --no-cache \
	&& addgroup -S -g 160 kube-apiserver \
	&& adduser  -S -g 160 -u 160 -G kube-apiserver -s /sbin/nologin kube-apiserver

USER kube-apiserver

COPY --from=builder /kube-apiserver /
