FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.8

RUN apk update --upgrade --no-cache \
	&& addgroup -S -g 161 kube-controller-manager \
	&& adduser  -S -g 161 -u 160 -G kube-controller-manager -s /sbin/nologin kube-controller-manager

USER kube-controller-manager

COPY --from=builder /kube-controller-manager /