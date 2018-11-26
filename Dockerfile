FROM whisperos/kube-builder:latest AS builder

FROM alpine:latest
RUN apk add --no-cache iptables ipset ipvsadm conntrack-tools
COPY --from=builder /kube-proxy /
