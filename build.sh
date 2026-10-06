#!/bin/bash
# ==============================================================================
# build.sh - Array-driven target selector
# ==============================================================================
set -euo pipefail

# --- 1. Target Definitions ---

declare -A target0=(
    [ARCH]=riscv
    [CROSS_COMPILE]=riscv64-unknown-linux-gnu-
    [DEFCONFIG]=riscv64_virt_64_debug_defconfig
    [NPROC]=1
    [V]=0
    [QEMU]=qemu-system-riscv64
)

declare -A target1=(
    [ARCH]=arm64
    [CROSS_COMPILE]=aarch64-linux-gnu-
    [DEFCONFIG]=aarch64_virt_64_debug_defconfig
    [NPROC]=$(nproc)
    [V]=1
    [QEMU]=qemu-system-aarch64
)

# --- 2. Help & Listing ---

print_help() {
    echo "Usage: ./build.sh [TARGET_ID]"
    echo ""
    echo "Available Targets:"
    
    local i=0
    # Loop dynamically as long as target$i exists
    while declare -p "target$i" &>/dev/null; do
        declare -n tgt="target$i"
        echo "  [$i] ARCH: ${tgt[ARCH]} | DEFCONFIG: ${tgt[DEFCONFIG]}"
        echo "      -> OUT_DIR: ${tgt[OUT_DIR]}"
        echo "      -> CC:      ${tgt[CROSS_COMPILE]}"
        echo ""
        unset -n tgt
        ((++i))
    done
    
    echo ""
    echo "Example: ./build.sh 0"
}

# --- 3. Build Execution ---

run_target() {
    local target_id=$1
    local target_name="target${target_id}"

    # Validate target exists
    if ! declare -p "$target_name" &>/dev/null; then
        echo -e "\n[ERROR] Target [$target_id] does not exist.\n"
        print_help
        exit 1
    fi

    # Create a nameref 'tgt' that points to the selected array
    declare -n tgt="$target_name"

    echo "============================================================"
    echo " BUILDING TARGET [$target_id] : ${tgt[ARCH]}"
    echo "============================================================"
    
    # Step A: Apply the defconfig to generate .config and auto.conf
    make ARCH="${tgt[ARCH]}" CROSS_COMPILE="${tgt[CROSS_COMPILE]}" V="${tgt[V]}" "${tgt[DEFCONFIG]}"
    echo ".config and auto.conf generated, now compiling..."
    # Step B: Compile the project
    make ARCH="${tgt[ARCH]}" CROSS_COMPILE="${tgt[CROSS_COMPILE]}" V="${tgt[V]}" -j"${tgt[NPROC]}"
}

# --- 4. Main Router ---

main() {
    # If no argument or help flag is passed, show targets
    if [[ $# -eq 0 ]]; then
        echo -e "\n[INFO] No target specified. Using default target 0.\n"
        run_target 0
        exit 0
    fi
    if [[ "$1" == "help" || "$1" == "-h" ]]; then
        print_help
        exit 0
    fi

    run_target "$1"
}

main "$@"