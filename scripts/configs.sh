#! /usr/bin/env bash

set -e

cat << EOF >> /etc/sysctl.conf
# antizapret values
# net.core.rmem_default = 262143
# net.core.rmem_max = 4194304
# net.core.wmem_default = 262143
# net.core.wmem_max = 4194304
net.ipv4.tcp_congestion_control = bbr
net.ipv4.conf.default.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_intvl = 120
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_rmem = 4096 262143 4194304
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_wmem = 4096 262143 4194304
net.netfilter.nf_conntrack_generic_timeout = 600
net.netfilter.nf_conntrack_icmp_timeout = 30
# net.netfilter.nf_conntrack_max=102400
net.netfilter.nf_conntrack_tcp_timeout_close = 10
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_established = 1800
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_last_ack = 30
net.netfilter.nf_conntrack_tcp_timeout_max_retrans = 300
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 60
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged = 300
net.netfilter.nf_conntrack_udp_timeout = 120
net.netfilter.nf_conntrack_udp_timeout_stream = 180
EOF

mkdir -p /var/{cache,lib}/knot-resolver
chown knot-resolver:knot-resolver -R /var/{cache,lib}/knot-resolver

cd /root/antizapret

rm /tmp/*
