FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.9

LABEL name="kube-scheduler" \
	version="1.13.3" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="the Kubernetes scheduler daemon" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk update --upgrade --no-cache

COPY --from=builder /kube-scheduler /
