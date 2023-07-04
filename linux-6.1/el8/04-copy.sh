#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e

_kver="$(ls -1 ~/rpmbuild/RPMS/x86_64/kernel-[1-9]*.rpm | sed 's|/|\n|g' | grep '\.rpm$' | sed -e 's|kernel-||g' -e 's|\.el[0-9].*||g' | sort -V | tail -n 1)"

_tmp_dir="/tmp/_output"
rm -fr "${_tmp_dir}"
mkdir "${_tmp_dir}"
cd "${_tmp_dir}"

install -m 0755 -d kernel/kernel-"${_kver}"-repos/packages
install -m 0755 -d kernel/assets
sleep 1
cd kernel/kernel-"${_kver}"-repos/packages/
find ~/rpmbuild/RPMS/ -type f -iname '*.rpm' | xargs --no-run-if-empty -I '{}' /bin/cp -v -a '{}' ./
sleep 2
sha256sum *.rpm > sha256sums.txt
sleep 2
cd ..
echo
createrepo -v .
echo
sleep 2
cd ..
tar -zcvf assets/kernel-"${_kver}"-repos.tar.gz kernel-"${_kver}"-repos

echo
echo ' done'
echo
exit

