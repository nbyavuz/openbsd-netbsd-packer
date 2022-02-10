#!/bin/ksh

pkg_add -uvI && \
pkg_add -I \
vim--no_x11 git \
bash \
curl \
git \
gmake \
meson \
pkgconf \
\
bison \
ccache \
gettext-tools \
\
p5-IPC-Run \
\
gssdp \
icu4c \
libxml \
libxslt \
lz4 \
openpam \
python%3.8 \
readline \
tcl%8.6 \
\
login_krb5 \
openldap-client--gssapi \
openldap-server--gssapi || true
