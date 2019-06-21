FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.10.0

LABEL name="kube-controller-manager" \
	version="1.15.0" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="the Kubernetes controller-manager daemon" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk update --upgrade --no-cache

COPY --from=builder /kube-controller-manager /

ENTRYPOINT /kube-controller-manager
