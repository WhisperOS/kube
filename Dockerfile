FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.10.0

LABEL name="kube-scheduler" \
	version="1.15.0" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="the Kubernetes scheduler daemon" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk upgrade --update --no-cache

COPY --from=builder /kube-scheduler /

ENTRYPOINT /kube-scheduler
