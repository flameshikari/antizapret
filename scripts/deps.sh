#! /usr/bin/env bash

set -e

cd /tmp

export S6_OVERLAY_VERSION=3.2.0.0
export S6_OVERLAY_URLS=(
    https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz
    https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz
)

export APT_LISTCHANGES_FRONTEND=none
export DEBIAN_FRONTEND=noninteractive

export APT_PACKAGES=(
    bsdmainutils
    ca-certificates
    curl
    dnsutils
    ferm
    gawk=1:4.2.1+dfsg-1
    git
    host
    idn
    inetutils-ping
    ipcalc
    iptables
    knot-resolver
    nano
    openssl
    openvpn
    procps
    python3-dnslib
    sipcalc
    speedometer
    vim-tiny
    wget
    xz-utils
)


echo 'deb http://deb.debian.org/debian buster main' >> /etc/apt/sources.list

apt-get update -q
apt-get install -qqy --no-install-suggests --no-install-recommends ${APT_PACKAGES[@]} 

git clone https://bitbucket.org/anticensority/antizapret-pac-generator-light.git /root/antizapret

for URL in ${S6_OVERLAY_URLS[@]}; do curl -s -L $URL | tar -Jxpf - -C /; done

apt-get autoremove -yq
apt-get clean -q
