#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

hostnamectl --static set-hostname 'x86-040.build.eng.bos.redhat.com' >/dev/null 2>&1 || :  
sleep 2
systemctl restart systemd-hostnamed.service >/dev/null 2>&1 || : 

exit
