FROM whisperos/kube-builder:latest AS builder

FROM alpine:latest
COPY --from=builder /kube-controller-manager /
