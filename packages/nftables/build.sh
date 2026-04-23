#!/bin/bash
# build.sh — nftables
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc     --with-json     --disable-debug
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install

# Basic ruleset
install -Dm644 /dev/stdin "$MEOW_STAGE/etc/nftables.conf" << 'EOF'
#!/usr/sbin/nft -f
# /etc/nftables.conf — base ruleset

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        ct state invalid drop
        iif lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        tcp dport 22 accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
