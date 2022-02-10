#!/bin/ksh

PKG_PATH="http://cdn.NetBSD.org/pub/pkgsrc/packages/NetBSD/$(uname -p)/$(uname -r|cut -f '1 2' -d.)/All/" && \
export PKG_PATH && \
/usr/sbin/pkg_add pkgin && \
/usr/pkg/bin/pkgin update && \
mkdir /usr/pkg/pgsql && \
/usr/pkg/bin/pkgin -y install \
curl \
vim \
git \
mozilla-rootcerts \
gmake \
meson \
bison \
ccache \
p5-IPC-Run \
flex \
pkgconf \
icu \
lz4 \
libxslt \
tcl && \
/usr/pkg/sbin/mozilla-rootcerts install && \
find /usr/pkg/lib/ -name libperl.so -exec ln -sf '{}' /usr/pkg/lib/libperl.so ';' && \
find /usr/pkg/bin -name python3.8 -exec ln -sf '{}' /usr/pkg/bin/python3 ';'