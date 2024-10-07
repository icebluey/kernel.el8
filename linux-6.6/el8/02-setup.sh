#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"

_linux_kernel_ver=$(ls -1 linux-*.tar.xz | sed -E 's/.*linux-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.xz/\1/')

IFS='.' read -r _major _minor _patch <<< "${_linux_kernel_ver}"
_patch=${_patch:-0}

rm -f kernel-"${_major}.${_minor}"*.spec

if ls .kernel-*.spec >/dev/null 2>&1; then
    cp -f .kernel-*.spec kernel-"${_major}.${_minor}.${_patch}".spec
    chmod 0644 kernel-*.spec
fi

_kernel_spec_file=kernel-"${_major}.${_minor}.${_patch}".spec

# 7
#%define pkg_release 1%{?buildid}%{?dist}
# 8
#%define pkg_release 1%{?dist}%{?buildid}

_datenow="$(date -u +%Y%m%d)"
sed "/^%define LKAver /s|LKAver .*|LKAver ${_linux_kernel_ver}|g" -i "${_kernel_spec_file}"
sed "/^%define pkg_release /s|pkg_release .*|pkg_release ${_datenow}%{?dist}%{?buildid}|g" -i "${_kernel_spec_file}"
sed 's|^NoSource:|#NoSource:|g' -i "${_kernel_spec_file}"

sed -e '/^%changelog/,$d' -i "${_kernel_spec_file}"
echo '%changelog' >> "${_kernel_spec_file}"

if [[ "${_patch}" > 0 ]]; then
    for (( i = "${_patch}"; i >= 0; i-- )); do
        if [[ ${i} == 0 ]]; then
            _changelog_date="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Date:' | sed 's/^Date://g' | sed "s/^[ \t]*//" | awk '{print $1,$2,$3,$5}')"
            _changelog_author="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Author:' | sed 's/^Author://g' | sed "s/^[ \t]*//")"
            echo "* ${_changelog_date} ${_changelog_author} - ${_major}.${_minor}" >> "${_kernel_spec_file}"
            echo "- Updated with the ${_major}.${_minor} source tarball." >> "${_kernel_spec_file}"
            echo "- [https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}]" >> "${_kernel_spec_file}"
        else
            _changelog_date="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}.${i}" | head -n 4 | grep -i '^Date:' | sed 's/^Date://g' | sed "s/^[ \t]*//" | awk '{print $1,$2,$3,$5}')"
            _changelog_author="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}.${i}" | head -n 4 | grep -i '^Author:' | sed 's/^Author://g' | sed "s/^[ \t]*//")"            
            echo "* ${_changelog_date} ${_changelog_author} - ${_major}.${_minor}.${i}" >> "${_kernel_spec_file}"
            echo "- Updated with the ${_major}.${_minor}.${i} source tarball." >> "${_kernel_spec_file}"
            echo "- [https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}.${i}]" >> "${_kernel_spec_file}"
        fi
    done
elif [[ "${_patch}" == "0" ]]; then
    _changelog_date="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Date:' | sed 's/^Date://g' | sed "s/^[ \t]*//" | awk '{print $1,$2,$3,$5}')"
    _changelog_author="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Author:' | sed 's/^Author://g' | sed "s/^[ \t]*//")"
    echo "* ${_changelog_date} ${_changelog_author} - ${_major}.${_minor}" >> "${_kernel_spec_file}"
    echo "- Updated with the ${_major}.${_minor} source tarball." >> "${_kernel_spec_file}"
    echo "- [https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}]" >> "${_kernel_spec_file}"
fi
echo >> "${_kernel_spec_file}"

echo
grep '%define LKAver' "${_kernel_spec_file}"
echo
grep -i 'https://www.kernel.org/pub/linux/kernel/' "${_kernel_spec_file}"

###############################################################################

rm -fr config-*
if [[ -f .config ]]; then
    cp -f .config config-"${_linux_kernel_ver}"-x86_64
    sleep 1
    sed -i -e "/Kernel Configuration/s|^# Linux/x86_64 .*Kernel Configuration|# Linux/x86_64 ${_linux_kernel_ver} Kernel Configuration|g" config-"${_linux_kernel_ver}"-x86_64
fi

echo
echo ' done'
exit

