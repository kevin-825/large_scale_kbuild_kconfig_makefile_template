# ============================================================================
# Build Profile Selection
# ============================================================================

pN ?= 0

# ============================================================================
# Common QEMU Arguments
# ============================================================================

qemu_base_args = \
	-M virt \
	-m 1024M \
	-nographic \
	-drive file=$(SDCARD_PATH),format=raw,id=hd0,if=none \
	-device virtio-blk-device,drive=hd0 \
	-netdev user,id=net0 \
	-device virtio-net-device,netdev=net0 \
	-append "root=/dev/vda2 rw rootwait console=ttyS0 earlycon=sbi"

# ============================================================================
# Profiles definiton
# ============================================================================

PROFILE_0_ARCH           := riscv
PROFILE_0_CROSS_COMPILE  := riscv64-unknown-linux-gnu-
PROFILE_0_DEFCONFIG      := riscv64_virt_64_debug_defconfig
PROFILE_0_NPROC          := 1
PROFILE_0_V              := 0
PROFILE_0_QEMU           := qemu-system-riscv64
PROFILE_0_QEMU_EXTRA_ARG :=



PROFILE_1_ARCH           := arm64
PROFILE_1_CROSS_COMPILE  := aarch64-none-linux-gnu-
PROFILE_1_DEFCONFIG      := aarch64_virt_64_debug_defconfig
PROFILE_1_NPROC          := $(shell nproc)
PROFILE_1_V              := 1
PROFILE_1_QEMU           := qemu-system-aarch64
PROFILE_1_QEMU_EXTRA_ARG :=

# ============================================================================
# Profile Validation
# ============================================================================
PROFILE_IDS = $(sort $(patsubst PROFILE_%_ARCH,%,$(filter PROFILE_%_ARCH,$(.VARIABLES))))
PROFILE_STR = [$(1)] ARCH=$(PROFILE_$(1)_ARCH) DEFCONFIG=$(PROFILE_$(1)_DEFCONFIG) V=$(PROFILE_$(1)_V) NPROC=$(PROFILE_$(1)_NPROC)

define print_all_profiles
$(info )
$(info Available profiles:)
$(info )
$(foreach p,$(PROFILE_IDS),$(info $(call PROFILE_STR,$(p))) $(info ) )
endef

ifeq ($(strip $(PROFILE_$(pN)_ARCH)),)
$(call print_all_profiles)
$(error Profile $(pN) does not exist)
endif

# ============================================================================
# Export Profile Defaults
# User may override on command line.
# ============================================================================
#
# Example:
#   make pN=0
#   make pN=0 V=1
#   make pN=1 CROSS_COMPILE=clang-
#

ARCH           ?= $(PROFILE_$(pN)_ARCH)
CROSS_COMPILE  ?= $(PROFILE_$(pN)_CROSS_COMPILE)
DEFCONFIG      ?= $(PROFILE_$(pN)_DEFCONFIG)
NPROC          ?= $(PROFILE_$(pN)_NPROC)
V              ?= $(PROFILE_$(pN)_V)
QEMU           ?= $(PROFILE_$(pN)_QEMU)
QEMU_EXTRA_ARG ?= $(PROFILE_$(pN)_QEMU_EXTRA_ARG)

export ARCH
export CROSS_COMPILE
export DEFCONFIG
export NPROC
export V

# ============================================================================
# Derived QEMU Variables
# ============================================================================

QEMU_ARGs := \
	$(qemu_base_args) \
	$(QEMU_EXTRA_ARG)

qemu_cmd := \
	$(QEMU) \
	$(QEMU_ARGs)

export qemu_cmd

SELECTED_PROFILE_STR = ARCH=$(ARCH) DEFCONFIG=$(DEFCONFIG) V=$(V) NPROC=$(NPROC)
$(info slected profile:)
$(info $(SELECTED_PROFILE_STR) )
$(info )

.PHONY: profile-help


profile-help:
	@echo
	@echo "Available profiles:"
	@echo
	@$(foreach p,$(PROFILE_IDS),echo " $(call PROFILE_STR,$(p))"; echo; )
