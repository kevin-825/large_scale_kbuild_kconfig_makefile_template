#!/bin/bash
set -euo pipefail

QEMU_BASE_ARG=" \
    -M virt \
    -m 1024M \
    -nographic \
    -device virtio-blk-device,drive=hd0 \
    -drive file=${SDCARD_PATH},format=raw,id=hd0,if=none \
    -netdev user,id=net0 \
    -device virtio-net-device,netdev=net0 \
    -kernel ${KERNEL_PATH} \
    -append 'root=/dev/vda2 rw rootwait initcall_debug console=ttyS0 earlycon=sbi'"


# Declare the associative array safely
declare -A profile0=(
    [ARCH]=riscv
    [CROSS_COMPILE]=riscv64-unknown-linux-gnu-
    [DEFCONFIG]=riscv64_virt_64_debug_defconfig
    [NPROC]=1
    [V]=0
    [QEMU]=qemu-system-riscv64 "$QEMU_BASE_ARG"
)

declare -A profile1=(
    [ARCH]=riscv
    [CROSS_COMPILE]=riscv64-unknown-linux-gnu-
    [DEFCONFIG]=riscv64_virt_64_debug_defconfig
    [NPROC]=$(nproc)
    [V]=1
    [QEMU]=qemu-system-riscv64 "$QEMU_BASE_ARG"
)

declare -A profile2=(
    [ARCH]=arm64
    [CROSS_COMPILE]=aarch64-linux-gnu-
    [DEFCONFIG]=aarch64_virt_64_debug_defconfig
    [NPROC]=$(nproc)
    [V]=1
    [QEMU]=qemu-system-aarch64 "$QEMU_BASE_ARG"
)


PRF_NUM=1
#[ !  declare -p "$profile${PRF_NUM}"] echo -e "\n[ERROR] Target [$target_id] does not exist.\n" && exit 1
declare -n pProfN="$profile${PRF_NUM}"

BASE_ARG='ARCH="${pProfN[ARCH]}" CROSS_COMPILE="${pProfN[CROSS_COMPILE]}" V="${pProfN[V]}"'


echo " make $BASE_ARG "


