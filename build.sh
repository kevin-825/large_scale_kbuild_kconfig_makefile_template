#!/usr/bin/env bash

set -euo pipefail

#SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
#TOP_DIR="${SCRIPT_DIR}"

#
# profile selection
#
pN=0

new_args=()
while (($#))
do
    case "$1" in
        -p|-pN)pN="$2"; shift 2;;
        *)new_args+=("$1"); shift;;
    esac
done
export pN=${pN}
echo 0pN:${pN}
# Replace positional arguments
set -- "${new_args[@]}"

echo ">>>>>>pN:${pN} [all_new_args:$@ ] <<<<<<<<<"

source scripts/env/build_profiles.env

echo 2pN:${pN}
echo make_args:${make_args}

print_selected_profile()
{
    echo ">>>>>>Selected Profile:"
    echo " [${pN}]   ARCH=${pBp[ARCH]} CROSS_COMPILE=${pBp[CROSS_COMPILE]} V=${pBp[V]}"
}
parse_args()
{
    while [[ $# -gt 0 ]]
    do
        case "$1" in
        
            -b) ACTION=build; make ${make_args} kernel -j$(NPROC); exit 0;;
            -cb) ACTION=clean_build; make ${make_args} clean defconfig kernel -j$(NPROC); exit 0;;
            -cbr) ACTION=clean_build_run; make ${make_args} clean defconfig qemu -j$(NPROC); exit 0;;
            -cbd) ACTION=clean_build_run_debug; make ${make_args} clean defconfig qemu_dbg -j$(NPROC); exit 0;;
            -cbdr) ACTION=clean_build_run_debug2; make ${make_args} clean defconfig qemu_dbg_run -j$(NPROC); exit 0;;
            -r) ACTION=run_only; make ${make_args} run -j$(NPROC); exit 0;;
            -rd) ACTION=run_only_debug; make ${make_args} run_dbg -j$(NPROC); exit 0;;
            -m) ACTION=new_menuconfig_save; make ${make_args} distclean menuconfig savedefconfig; exit 0;;
            -u) ACTION=update_defconfig; make ${make_args} distclean defconfig menuconfig savedefconfig; exit 0;;

            -p) echo "[ERROR] -p option should be removed, and this case shouldn't be entered!"; exit 1;;

            -h|--help) usage; exit 0;;

            *) make ${make_args} $@; exit 0;;  
        esac
    done
}
usage()
{
    cat <<EOF

Usage:
    ./build.sh [profile] [option]

Profile:
    -p <num>     Select build profile (0-99)
                 Default: 0

Options:

    -b           defconfig + build

    -cb          clean + defconfig + build

    -cbr         clean + defconfig + build + run qemu

    -cbd         clean + defconfig + build + start qemu debug

    -cbdr        clean + defconfig + build + start qemu debug + run

    -r           run existing build

    -rd          run existing build in debug mode

    -u           distclean + menuconfig + savedefconfig

    -h           show this help

Examples:

    ./build.sh -b

    ./build.sh -cb

    ./build.sh -cbr

    ./build.sh -rd

    ./build.sh -p 1 -cb

    ./build.sh -p 15 -cbr

Notes:

    If -p is omitted, profile 0 is used.

EOF
}
main(){
    parse_args "$@"
}
main $@