FROM whisperos/kube-builder:latest AS builder

FROM alpine:3.10.0

LABEL name="kube-proxy" \
	version="1.15.0" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="the Kubernetes network service abstraction daemon" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk update \
	&& apk upgrade \
	&& apk add --no-cache ipset ipvsadm conntrack-tools libpcap libmnl libnftnl-libs libnetfilter_conntrack \
	&& apk add --no-cache --virtual .build-dependencies curl make gcc musl-dev flex bison autoconf automake \
		libtool libpcap-dev libmnl-dev linux-headers libnftnl-dev file libnetfilter_conntrack-dev \
	&& mkdir /root/iptables && cd /root/iptables \
	&& curl https://www.netfilter.org/projects/iptables/files/iptables-1.8.2.tar.bz2 \
		| tar xj --strip-components=1 -C . \
	&& autoreconf -i -f \
	&& ./configure CFLAGS="-O2 -pipe" --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --enable-shared \
		--enable-nftables --enable-bpf-compiler --enable-nfsynproxy --disable-static --enable-ipv6 --enable-connlabel \
	&& sed -i -e '/if_ether.h/d' extensions/libebt_vlan.c \
	&& make -j4 \
	&& make DESTDIR=/root/iptables-release install \
	&& rm -rf /root/iptables-release/usr/share \
	&& rm -rf /root/iptables-release/usr/doc \
	&& rm -rf /root/iptables-release/usr/include \
	&& find   /root/iptables-release -path \*bin\* -type f | xargs strip \
	&& find   /root/iptables-release -name \*.so\* | xargs strip \
	&& cd / \
	&& cp -R  /root/iptables-release/* / \
	&& rm -rf /root/iptables-release /root/iptables \
	&& apk del .build-dependencies \
	&& rm -rf /var/cache/apk/*

COPY --from=builder /kube-proxy /

ENTRYPOINT /kube-proxy
