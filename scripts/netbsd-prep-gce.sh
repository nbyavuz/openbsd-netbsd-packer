#!/bin/ksh

# Network
cat > /etc/ifconfig.wm0 << EOF
!dhcpcd wm0
mtu 1460
EOF
