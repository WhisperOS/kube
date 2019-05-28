FROM alpine:3.9.4

RUN apk update \
	&& apk upgrade \
	&& apk add json-c openssl ipset libnl3 libnfnetlink libevent \
		iproute2 gmp unbound-libs libldap ldns libcurl libpcap \
		libmnl libnftnl-libs libnetfilter_conntrack libnl3 libnfnetlink \
	&& apk add --no-cache --virtual .build-dependencies \
		gcc make musl-dev curl-dev curl json-c-dev openssl-dev linux-headers libtool \
		autoconf automake ipset-dev libnl3-dev libnfnetlink-dev \
		pkgconf libevent-dev flex bison gettext-dev gmp-dev file openldap-dev \
		unbound-dev  ldns-dev libpcap-dev libmnl-dev libnetfilter_conntrack-dev \
		libnftnl-dev \
	\
	&& mkdir /root/iptables && cd /root/iptables \
	&& curl https://www.netfilter.org/projects/iptables/files/iptables-1.8.3.tar.bz2 \
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
	&& mkdir /root/strongswan && cd /root/strongswan \
	&& curl https://download.strongswan.org/strongswan-5.8.0.tar.gz | tar xz --strip-components=1 -C . \
	&& autoreconf -i -f \
	\
	&& ./configure --prefix=/usr --sysconfdir=/etc --enable-connmark --enable-ha --enable-counters \
		 --enable-swanctl --enable-ipsec2 --enable-gmp --enable-curl --enable-unbound --enable-ldap \
		 --enable-socket-dynamic \
		 --enable-sha3 --enable-aesni --enable-gcm \
		 --enable-openssl \
		 --enable-eap-identity \
		 --enable-eap-mschapv2 \
		 --enable-eap-radius \
		 --enable-eap-tls \
		 --enable-xauth-eap \
		 --enable-eap-dynamic \
	\
	&& make -j4 \
	&& make DESTDIR=/root/strongswan-release install \
	&& find   /root/strongswan-release -path \*bin\* -type f -not -path \*sbin/ipsec | xargs strip \
	&& find   /root/strongswan-release -name \*.so\* | xargs strip \
	&& apk del .build-dependencies \
	&& rm -rf /root/strongswan-release/usr/share \
	&& rm -rf /root/strongswan-release/usr/man \
	&& rm -rf /root/strongswan-release/usr/doc \
	&& rm -rf /root/strongswan-release/usr/lib/ipsec/*.la \
	&& rm -rf /root/strongswan-release/usr/lib/ipsec/plugins/*.la \
	&& cp -R /root/strongswan-release/* / \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /root/strongswan && rm -rf /root/strongswan-release

# vi:syntax=dockerfile
