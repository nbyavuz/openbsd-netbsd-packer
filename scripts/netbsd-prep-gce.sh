#!/bin/ksh

# Network
cat > /etc/ifconfig.vioif0 << EOF
!dhcpcd vioif0
mtu 1460
EOF
