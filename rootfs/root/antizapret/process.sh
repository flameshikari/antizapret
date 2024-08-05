#!/bin/bash
set -e

HERE="$(dirname "$(readlink -f "${0}")")"
cd "$HERE"

cp result/knot-aliases-alt.conf /etc/knot-resolver/knot-aliases-alt.conf

/command/s6-svc -r /var/run/s6/legacy-services/kresd || true

cp result/openvpn-blocked-ranges.txt /etc/openvpn/server/ccd/DEFAULT
iptables -F azvpnwhitelist
while read -r line
do
    iptables -w -A azvpnwhitelist -d "$line" -j ACCEPT
done < result/blocked-ranges.txt

exit 0