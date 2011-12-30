#!/bin/bash
#
# eva2000make - wrapper for compiling a kernel for the EVA2000
#
# Florian <florian.hostoi.com>
#
# How to build the kernel:
# 1. Download required sources: a) wget ftp://downloads.netgear.com/files/GPL/EVA2000_v4.9.0.11.2.3.9_src.tar.bz2.zip
#								b) git clone https://github.com/floriandejonckheere/scripts.git
# 2. Extract a): unzip EVA2000_v4.9.0.11.2.3.9_src.tar.bz2.zip && tar jxvf EVA2000_v4.9.0.11.2.3.9_src.tar.bz2 -C /path/to/builddir
# 3. Copy patches and script to builddir
# 4. source ./eva2000make.sh
# 5. make clean
# 6. make
#
# Following instructions in Opensource_README.txt is not necessary. This script takes care of everything.
#
PATCHES=("LinuxMakefile.patch" "sumversion.patch")
BINDEPS=("dc")

for BIN in ${BINDEPS[@]}; do
	[ ! $BIN ] && echo "Command $BIN not found." && exit 1
done
[ ! -d toolchain/bin ] && echo "Toolchain not found. Did you place this script in the right directory?" && exit 1
for PATCH in ${PATCHES[@]}; do
	[ ! -f $PATCH ] && echo "$PATCH not found." && exit 1
done
for PATCH in ${PATCHES[@]}; do
	patch --dry-run -Np0 < $PATCH || echo && echo "> Error while applying patch $PATCH"
	echo
done

# toolchain-env
if [ ! -d /opt/toolchain ]; then
	echo "Copying toolchain to /opt..."
	sudo mkdir -p /opt/toolchain
	sudo cp -R toolchain/* /opt/toolchain || echo "Copying failed." && exit 1
	echo "Toolchain copied."
else
	echo "Toolchain exists in /opt/toolchain."
fi
export IT_PATH_ORIG=${PATH};
PRJROOT=/opt/toolchain
TOOLCHAIN=/opt/toolchain
PATH=${TOOLCHAIN}/bin:${IT_PATH_ORIG}
SU=sudo

export PRJROOT TOOLCHAIN PATH SU 

echo
echo "You're all set now. Execute 'make clean', and then 'make' to start compiling."
