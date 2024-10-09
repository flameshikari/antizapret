#!/bin/bash
set -e

HERE="$(dirname "$(readlink -f "${0}")")"
cd "$HERE"

source config/config.sh

# Extract domains from list
if [[ $SKIP_UPDATE_FROM_ZAPRET == false ]]; then
   awk -F ';' '{print $2}' temp/list.csv | sort -u | awk '/^$/ {next} /\\/ {next} /^[а-яА-Яa-zA-Z0-9\-_\.\*]*+$/ {gsub(/\*\./, ""); gsub(/\.$/, ""); print}' | grep -Fv 'bеllonа' | CHARSET=UTF-8 idn --no-tld | grep -Fv 'xn--' > result/hostlist_original.txt
else
   echo \n > result/hostlist_original.txt
fi

for file in config/custom/{include,exclude}-hosts-custom.txt; do
    basename=$(basename $file | sed 's|-custom.txt||')
    sort -u $file config/${basename}-dist.txt > temp/${basename}.txt
done
sort -u temp/include-hosts.txt result/hostlist_original.txt > temp/hostlist_original_with_include.txt

awk -F ';' '{split($1, a, /\|/); for (i in a) {print a[i]";"$2}}' temp/list.csv | \
 grep -f config/exclude-hosts-by-ips-dist.txt | awk -F ';' '{print $2}' >> temp/exclude-hosts.txt

awk -f scripts/getzones.awk temp/hostlist_original_with_include.txt | grep -v -F -x -f temp/exclude-hosts.txt | sort -u > result/hostlist_zones.txt

if [[ "$RESOLVE_NXDOMAIN" == "yes" ]];
then
    timeout 2h scripts/resolve-dns-nxdomain.py result/hostlist_zones.txt > temp/nxdomain-exclude-hosts.txt
    cat temp/nxdomain-exclude-hosts.txt >> temp/exclude-hosts.txt
    awk -f scripts/getzones.awk temp/hostlist_original_with_include.txt | grep -v -F -x -f temp/exclude-hosts.txt | sort -u > result/hostlist_zones.txt
fi

# Generate a list of IP addresses
# awk -F';' '$1 ~ /\// {print $1}' temp/list.csv | grep -P '([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}' -o | sort -Vu > result/iplist_special_range.txt
# awk -F ';' '($1 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}/) {gsub(/\|/, RS, $1); print $1}' temp/list.csv | \
#     awk '/^([0-9]{1,3}\.){3}[0-9]{1,3}$/' | sort -u > result/iplist_all.txt
# awk -F ';' '($1 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}/) && (($2 == "" && $3 == "") || ($1 == $2)) {gsub(/\|/, RS); print $1}' temp/list.csv | \
#     awk '/^([0-9]{1,3}\.){3}[0-9]{1,3}$/' | sort -u > result/iplist_blockedbyip.txt
# grep -F -v '33-4/2018' temp/list.csv | grep -F -v '33а-5536/2019' | \
#     awk -F ';' '($1 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}/) && (($2 == "" && $3 == "") || ($1 == $2)) {gsub(/\|/, RS); print $1}' | \
#     awk '/^([0-9]{1,3}\.){3}[0-9]{1,3}$/' | sort -u > result/iplist_blockedbyip_noid2971.txt
awk -F ';' '$1 ~ /\// {print $1}' temp/list.csv | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}' | sort -u > result/blocked-ranges.txt


# Generate OpenVPN route file
echo -n > result/openvpn-blocked-ranges.txt
while read -r line
do
    C_NET="$(echo $line | awk -F '/' '{print $1}')"
    C_NETMASK="$(sipcalc -- "$line" | awk '/Network mask/ {print $4; exit;}')"
    echo $"push \"route ${C_NET} ${C_NETMASK}\"" >> result/openvpn-blocked-ranges.txt
done < result/blocked-ranges.txt

# Generate adguardhome aliases
/bin/cp --update=none /root/adguardhome/* /opt/adguardhome/conf
/bin/cp -f /opt/adguardhome/conf/upstream_dns_file_basis /opt/adguardhome/conf/upstream_dns_file
while read -r line
do
    echo "[/$line/]127.0.0.4" >> /opt/adguardhome/conf/upstream_dns_file
done < result/hostlist_zones.txt

# # Generate dnsmasq aliases
# echo -n > result/dnsmasq-aliases-alt.conf
# while read -r line
# do
#     echo "server=/$line/127.0.0.4" >> result/dnsmasq-aliases-alt.conf
# done < result/hostlist_zones.txt


# # Generate knot-resolver aliases
# echo 'blocked_hosts = {' > result/knot-aliases-alt.conf
# while read -r line
# do
#     line="$line."
#     echo "${line@Q}," >> result/knot-aliases-alt.conf
# done < result/hostlist_zones.txt
# echo '}' >> result/knot-aliases-alt.conf


# # Generate squid zone file
# echo -n > result/squid-whitelist-zones.conf
# while read -r line
# do
#     echo ".$line" >> result/squid-whitelist-zones.conf
# done < result/hostlist_zones.txt


# Print results
echo "Blocked domains: $(wc -l result/hostlist_zones.txt)" >&2

exit 0
