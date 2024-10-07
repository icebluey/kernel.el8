## Repo
```
[rhel-8-for-x86_64-kernel-rpms]
baseurl = file:///.repos/kernel
name = Red Hat Enterprise Linux 8 for x86_64 - Kernel (RPMs)
enabled = 1
gpgcheck = 0
proxy=_none_
```

```
cp -vf ../.config .config
make -s ARCH=x86_64 listnewconfig | grep -E '^CONFIG_'

make ARCH=x86_64 oldconfig

```
