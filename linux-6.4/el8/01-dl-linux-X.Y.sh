#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"

if [ $# -lt 1 ]; then
  echo "Usage: $0 X.Y"
  exit 1
fi

IFS='.' read -r _major _minor _patch <<< "$1"

echo
echo " Download linux kernel: v$1"
echo

_download_link=$(wget -qO- "https://www.kernel.org/" | grep -Po 'https://cdn\.kernel\.org/pub/linux/kernel/v[0-9]+\.x/linux-[0-9]+\.[0-9]+\.[0-9]+\.tar\.xz' | sort -V | uniq | grep "linux-${_major}\.${_minor}")
_filename="${_download_link##*/}"
wget -c -t 9 -T 9 "https://cdn.kernel.org/pub/linux/kernel/v${_major}.x/${_filename}"
_hash=$(wget -qO- "https://cdn.kernel.org/pub/linux/kernel/v${major}.x/sha256sums.asc" | awk -v filename="$_filename" '$0 ~ filename {print $2,$1}' | sort -V | tail -n1 | awk '{print $NF}')
if [[ -n $_hash ]]; then
    echo "$_hash  $_filename" > "${_filename}.sha256"
    sha256sum -c "${_filename}.sha256"
    echo
    rm -f "${_filename}.sha256"
fi

echo
echo ' done'
exit

