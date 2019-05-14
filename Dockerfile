FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.9.3

LABEL name="kubelet" \
	version="1.14.1" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="the Kubernetes System daemon" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk upgrade --update --no-cache

COPY --from=builder /kubelet /

ENTRYPOINT /kubelet
