#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"
bash 99-clean.sh
bash 01-dl-linux-X.Y.sh "6.1"
bash 02-setup.sh
bash 03-run.sh || tail -n 100 /tmp/make_rpm-pkg.log
echo ; grep '^CONFIG_' /tmp/make_rpm-pkg.log || : ; echo
tail -n 7 /tmp/make_rpm-pkg.log
bash 04-copy.sh
exit
