# Initialize an empty PHONY variable to collect non-file targets
PHONY :=

# Default target (must be first)
PHONY += all
all: kernel

-include scripts/Makefile.build_profiles


ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif
ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet = quiet_
  Q = @
endif

export Q

ARCH ?= riscv
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
#DEFCONFIG ?= riscv64_virt_64_debug_defconfig
export ARCH CROSS_COMPILE

CC      := $(CROSS_COMPILE)gcc
LD      := $(CROSS_COMPILE)ld
AR      := $(CROSS_COMPILE)ar
AS      := $(CROSS_COMPILE)as
GDB     := $(CROSS_COMPILE)gdb
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump
SIZE    := $(CROSS_COMPILE)size
# Add this near line 25 where you define OBJCOPY, OBJDUMP, etc.
NM      := $(CROSS_COMPILE)nm
export CC LD AR AS GDB OBJCOPY OBJDUMP SIZE NM
$(info slected profile:)
$(info [$(pN)] $(SELECTED_PROFILE_STR) )
$(info )

ifeq ($(origin O), command line)
  BUILD_DIR := $(O)
else
  BUILD_DIR := build_$(ARCH)
endif

srctree := $(CURDIR)
objtree := $(abspath $(BUILD_DIR))

TARGET := $(objtree)/vmkxv6.elf

export srctree objtree TARGET

CFLAGS := -Wall -Wextra -Werror -g -ffreestanding -nostdlib -ffunction-sections -fdata-sections
AFLAGS := -D__ASSEMBLY__ -g -ffreestanding -nostdlib
export CFLAGS AFLAGS

DOTCONFIG   := $(srctree)/.config
CONF_DIR    := $(objtree)/include/config
GEN_DIR     := $(objtree)/include/generated
AUTOCONF_H  := $(GEN_DIR)/autoconf.h
AUTO_CONF   := $(CONF_DIR)/auto.conf


#Configuration Targets
PHONY += menuconfig
menuconfig:FORCE
	@echo "  MENUCONFIG"
	$(Q)menuconfig $(srctree)/Kconfig

PHONY += savedefconfig
savedefconfig:FORCE
	@echo "  SAVEDEFCONFIG defconfig"
	$(Q)savedefconfig \
		--kconfig $(srctree)/Kconfig \
		--out $(srctree)/defconfig

# implicit pattern rules (like %_defconfig:) never match targets marked as .PHONY
#ifneq ($(filter %_defconfig,$(MAKECMDGOALS)),)
#  PHONY += $(MAKECMDGOALS)
#endif

# Default profile defconfig
PHONY += defconfig
defconfig: FORCE
	@echo "  DEFCONFIG $(DEFCONFIG)"
	$(Q)mkdir -p $(CONF_DIR) $(GEN_DIR)
	$(Q)defconfig \
		--kconfig "$(srctree)/Kconfig" \
		"$(srctree)/arch/$(ARCH)/configs/$(notdir $@)"

%_defconfig: FORCE
	@echo "  DEFCONFIG $@"
	$(Q)mkdir -p $(CONF_DIR) $(GEN_DIR)
	$(Q)defconfig \
		--kconfig "$(srctree)/Kconfig" \
		"$(srctree)/arch/$(ARCH)/configs/$(notdir $@)"

-include $(AUTO_CONF)
include $(srctree)/arch/$(ARCH)/Makefile
-include $(srctree)/scripts/Makefile.qemu

$(AUTO_CONF) $(AUTOCONF_H): $(DOTCONFIG)
	@echo "  SYNC $@"
	$(Q)mkdir -p $(CONF_DIR) $(GEN_DIR)
	$(Q)genconfig \
		--header-path $(AUTOCONF_H) \
		--sync-deps $(CONF_DIR) \
		--config-out $(DOTCONFIG) \
		$(srctree)/Kconfig


$(TARGET): $(AUTO_CONF) $(AUTOCONF_H) $(objtree)/built-in.a
	@echo "  BUILD kernel"
	@echo "  LD      vmkxv6.elf"
	$(Q)$(LD) --gc-sections \
		-Map=$(objtree)/vmkxv6.map \
		-T $(srctree)/arch/$(ARCH)/kernel/vmkxv6.lds \
		--whole-archive $(objtree)/built-in.a \
		--no-whole-archive \
		-o $@

	@echo "  OBJCOPY vmkxv6.bin"
	$(Q)$(OBJCOPY) -O binary $@ $(objtree)/vmkxv6.bin

	@echo "  NM      System.map"
	$(Q)$(NM) -n $@ > $(objtree)/System.map

	@echo "  OBJDUMP vmkxv6.asm"
	$(Q)$(OBJDUMP) -S -d $@ > $(objtree)/vmkxv6.asm

	@echo "  SIZE    vmkxv6.elf"
	$(Q)$(SIZE) $@


$(objtree)/built-in.a:
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.build obj=.

kernel: $(TARGET)


PHONY += clean
clean:
	@echo "  CLEAN"
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.clean obj=.

PHONY += distclean
distclean: clean
	@echo "  DISTCLEAN"
	$(Q)rm -f $(srctree)/.config $(srctree)/.config.old $(srctree)/.*.cmd  $(srctree)/.*.d
	$(Q)rm -rf $(objtree)

.PHONY: $(PHONY)