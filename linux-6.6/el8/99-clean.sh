#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
cd "$(dirname "$0")"
rm -f linux-*.tar*
rm -f config-*
rm -f kernel-*.spec
rm -fr ~/rpmbuild
rm -fr /tmp/_output
rm -f /tmp/make_rpm-pkg.log
rm -f /tmp/build-linux-kernel-done.txt
exit
