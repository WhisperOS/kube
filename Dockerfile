FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.8

RUN apk update --upgrade --no-cache \
	&& addgroup -S -g 162 kube-scheduler \
	&& adduser  -S -g 162 -u 162 -G kube-scheduler -s /sbin/nologin  kube-scheduler

USER kube-scheduler

COPY --from=builder /kube-scheduler /
