FROM alpine:3.10.0

LABEL name="keepalived" \
	version="2.0.17" \
	release="0" \
	architecture="x86_v64" \
	atomic.type="system" \
	summary="simple and robust facilities for loadbalancing and high-availability" \
	maintainer="Dan Molik <dan@whisperos.org>"

RUN apk update \
	&& apk upgrade \
	&& apk add json-c openssl ipset ipvsadm conntrack-tools libpcap \
		libmnl libnftnl-libs libnftnl libnetfilter_conntrack libnl3 libnfnetlink \
	&& apk add --no-cache --virtual .build-dependencies \
		libtool gcc make musl-dev curl json-c-dev openssl-dev linux-headers \
		autoconf automake ipset-dev  libnl3-dev libnfnetlink-dev bison flex file \
		libpcap-dev libmnl-dev libnftnl-dev libnetfilter_conntrack-dev libnftnl-dev \
	\
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
	&& find   /root/iptables-release -path \*bin\* -type f | xargs strip \
	&& find   /root/iptables-release -name \*.so\* | xargs strip \
	&& cd / \
	&& cp -R  /root/iptables-release/* / \
	&& rm -rf /root/iptables-release /root/iptables \
	\
	&& mkdir /root/keepalived && cd /root/keepalived \
	&& curl https://www.keepalived.org/software/keepalived-2.0.17.tar.gz \
		| tar xz --strip-components=1 -C . \
	&& sed -i 's/__always_inline//' lib/rbtree.c \
	&& sed -i 's/__always_inline//' lib/rbtree_augmented.h \
	&& autoreconf -i -f \
	&& ./configure --prefix=/usr --sysconfdir=/etc --enable-sha1 --enable-json --enable-vrrp \
	&& make -j4 \
	&& make DESTDIR=/root/keepalived-release install \
	&& strip /root/keepalived-release/usr/sbin/keepalived \
	&& apk del .build-dependencies \
	&& rm -rf /root/keepalived-release/etc \
	&& rm -rf /root/keepalived-release/usr/share \
	&& rm -rf /root/keepalived-release/usr/doc \
	&& cp -R /root/keepalived-release/* / \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /root/keepalived && rm -rf /root/keepalived-release
	# && sed -i '1s/^/#include\ <stdbool.h>\n/' keepalived/core/process.c \

ENTRYPOINT /usr/sbin/keepalived
