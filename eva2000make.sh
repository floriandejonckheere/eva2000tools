#!/bin/bash
#
# eva2000make - wrapper for compiling a kernel for the EVA2000
#
# Florian <floriandejonckheere.be>
#
# How to build the kernel:
# 1. Download required sources: a) wget ftp://downloads.netgear.com/files/GPL/EVA2000_v4.9.0.11.2.3.9_src.tar.bz2.zip
#								b) git clone https://github.com/floriandejonckheere/scripts.git
# 2. Extract a): unzip EVA2000_v4.9.0.11.2.3.9_src.tar.bz2.zip && tar jxvf EVA2000_v4.9.0.11.2.3.9_src.tar.bz2 -C /path/to/builddir
# 3. Copy patches and script to builddir
# 4. [ dry_run=1; ] source ./eva2000make.sh # IMPORTANT to source the script, do NOT execute it
# 5. make clean
# 6. make
#
# Following instructions in Opensource_README.txt is not necessary. This script takes care of everything. This script might need root
# privileges to copy the toolchain to /opt.
#
PATCHES=("LinuxMakefile.patch" "sumversion.patch" "config_hz.patch")
BINDEPS=("dc")


[ "$dry_run" = 1 ] && DRYRUN="--dry-run" && echo "Dry-run detected." && echo
for BIN in ${BINDEPS[@]}; do
	[ ! $BIN ] && echo "Command $BIN not found." && exit 1
done
[ ! -d toolchain/bin ] && echo "Toolchain not found. Did you place this script in the right directory?" && exit 1
for PATCH in ${PATCHES[@]}; do
	[ ! -f $PATCH ] && echo "$PATCH not found." && exit 1
done
for PATCH in ${PATCHES[@]}; do
	echo "Patching file(s) using $PATCH..."
	patch $DRYRUN -Np0 < $PATCH && echo "Patching complete." || echo && [ ! $DRYRUN ] && echo "> Error while applying patch $PATCH"
	echo
done

# toolchain-env
if [ ! -d /opt/toolchain ]; then
	echo "Copying toolchain to /opt..."
	sudo mkdir -p /opt/toolchain
	[ ! $DRYRUN ] && sudo cp -R toolchain/* /opt/toolchain && echo "Toolchain copied." || echo "Copying toolchain to /opt failed." && exit 1
elif [ arm-linux-gcc ]; then
	echo "Toolchain exists in /opt/toolchain."
else
	echo "Toolchain binaries could not be found! && exit 1"
fi
IT_PATH_ORIG=${PATH};
PRJROOT=/opt/toolchain
TOOLCHAIN=/opt/toolchain
PATH=${TOOLCHAIN}/bin:${IT_PATH_ORIG}
SU=sudo

[ ! $DRYRUN ] && export PRJROOT TOOLCHAIN PATH SU

[ $DRYRUN ] && echo "Dry run complete."
unset -v dry_run DRYRUN
echo
echo "You're all set now. Execute 'make clean', and then 'make' to start compiling."
