FROM whisperos/etcd-builder:latest AS builder

FROM alpine:3.9.3

LABEL name="etcd" \
	version="" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="Etcd distributed reliable k/v datastore" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk upgrade --update --no-cache

COPY --from=builder /build/etcd /
COPY --from=builder /build/etcdctl /

ENTRYPOINT /etcd
