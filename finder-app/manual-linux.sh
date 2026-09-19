#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    # like in the video
    # build clean 
    # i belive that we can also use make mrproper because we ARCH= AND CROSS_COMPILE= is have writen but idk
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper # deletes all the old builds
    # build defconfig 
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
    # build vmlinux
    # this is the instruction when i watch the video but i learned j is job here and use 4 processer with make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    # with nproc variable we can use all the available processor.
    make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    # build modules and device tree
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs
fi

echo "Adding the Image in outdir"
# i forgot this.
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs
mkdir -p ${OUTDIR}/rootfs/etc       # conf files
mkdir -p ${OUTDIR}/rootfs/dev       # device nodes
mkdir -p ${OUTDIR}/rootfs/proc      # proc and sys psudeo system filessystem
mkdir -p ${OUTDIR}/rootfs/sys
mkdir -p ${OUTDIR}/rootfs/lib       # for shared libs and modules
mkdir -p ${OUTDIR}/rootfs/lib64
mkdir -p ${OUTDIR}/rootfs/bin       # binaries
mkdir -p ${OUTDIR}/rootfs/sbin      # binaries for system administrators
mkdir -p ${OUTDIR}/rootfs/home

# other filesystems
mkdir -p ${OUTDIR}/rootfs/tmp       # temporary files
mkdir -p ${OUTDIR}/rootfs/usr/bin   # user binaries
mkdir -p ${OUTDIR}/rootfs/usr/sbin  # user binaries for system administrators
mkdir -p ${OUTDIR}/rootfs/usr/lib   # user libraries
mkdir -p ${OUTDIR}/rootfs/var/log   # log files


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd ${OUTDIR}/rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot) # this is our aarch64-none-linux-gnu- because we say gcc . we get sysroot as path. 

# now we copy this libraries into out embedded file system
cp -a ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/ # it might be in lib we might change it
cp -a ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/ # 
cp -a ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/
cp -a ${SYSROOT}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64/

# TODO: Make device nodes
cd ${OUTDIR}/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp writer ${OUTDIR}/rootfs/home/
cp finder.sh ${OUTDIR}/rootfs/home/
cp finder-test.sh ${OUTDIR}/rootfs/home/
cp autorun-qemu.sh ${OUTDIR}/rootfs/home/
cp -r conf/ ${OUTDIR}/rootfs/home/

# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
sudo chown -R root:root .

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio

cd ${OUTDIR}
gzip -f initramfs.cpio