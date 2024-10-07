#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"
systemctl start docker
sleep 5
docker run --cpus="2.0" --hostname 'x86-040.build.eng.bos.redhat.com' --rm --name al8 -itd icebluey/almalinux:8 bash
sleep 2
docker exec al8 yum clean all
docker exec al8 yum makecache
docker exec al8 /bin/bash -c 'rm -fr /tmp/*'
docker cp el8 al8:/home/
docker exec al8 /bin/bash /home/el8/00-run-all.sh
rm -fr /home/.tmp.kernel
mkdir /home/.tmp.kernel
docker cp al8:/tmp/_output /home/.tmp.kernel/
exit
