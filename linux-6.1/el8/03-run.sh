#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"

# Set back to system openssl 1.1.1
rm -f /usr/lib64/libcrypto.so.81.3
rm -f /usr/lib64/libssl.so.81.3
rm -f /usr/lib64/libcrypto.a
rm -f /usr/lib64/libssl.a
rm -fr /usr/include/openssl
rm -f /usr/lib64/pkgconfig/libcrypto.pc
rm -f /usr/lib64/pkgconfig/libssl.pc
rm -f /usr/lib64/pkgconfig/openssl.pc
rm -f /usr/bin/openssl
rm -f /usr/lib64/libcrypto.so
rm -f /usr/lib64/libssl.so
yum reinstall -y openssl-libs
yum reinstall -y openssl
yum reinstall -y openssl-devel

/sbin/ldconfig
rm -fr ~/rpmbuild
rm -fr /tmp/make_rpm-pkg.log
rm -fr /tmp/build-linux-kernel-done.txt

_start_epoch="$(date -u +%s)"
starttime="$(echo ' Start Time:  '"$(date -ud @"${_start_epoch}")")"
sleep 1
echo " ${starttime}" > /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log
###############################################################################
mkdir -p ~/rpmbuild/SOURCES
cp -pf sources/* ~/rpmbuild/SOURCES/
cp -pf config-*-x86_64 kernel*.spec linux-*.tar.xz ~/rpmbuild/SOURCES/
sleep 2
cd /tmp
rpmbuild -v -ba ~/rpmbuild/SOURCES/kernel*.spec >> /tmp/make_rpm-pkg.log 2>&1
echo >> /tmp/make_rpm-pkg.log
sleep 10
rpmbuild -v --target noarch -bb ~/rpmbuild/SOURCES/kernel*.spec >> /tmp/make_rpm-pkg.log 2>&1
echo >> /tmp/make_rpm-pkg.log
sleep 10
###############################################################################

_end_epoch="$(date -u +%s)"
finishtime="$(echo ' Finish Time:  '"$(date -ud @"${_end_epoch}")")"
_del_epoch=$((${_end_epoch} - ${_start_epoch}))
_elapsed_days=$((${_del_epoch} / 86400))
_del_mod_days=$((${_del_epoch} % 86400))
elapsedtime="$(echo 'Elapsed Time:  '"${_elapsed_days} days ""$(date -u -d @${_del_mod_days} +"%T")")"

echo " ${starttime}" >> /tmp/make_rpm-pkg.log
echo "${finishtime}" >> /tmp/make_rpm-pkg.log
echo "${elapsedtime}" >> /tmp/make_rpm-pkg.log

echo >> /tmp/make_rpm-pkg.log
echo '  build linux rpms done' >> /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log

###############################################################################

cd /tmp
echo 'done' > /tmp/build-linux-kernel-done.txt
exit
