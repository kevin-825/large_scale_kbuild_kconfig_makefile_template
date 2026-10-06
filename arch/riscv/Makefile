# arch/riscv/Makefile

# 1. Base ISA and ABI
riscv-march-$(CONFIG_ARCH_RV32I) := rv32i
riscv-mabi-$(CONFIG_ARCH_RV32I)  := ilp32

riscv-march-$(CONFIG_ARCH_RV64I) := rv64i
riscv-mabi-$(CONFIG_ARCH_RV64I)  := lp64

# 2. ISA Extensions (Appended in strict RISC-V order)
riscv-march-$(CONFIG_RISCV_ISA_M) := $(riscv-march-y)m
riscv-march-$(CONFIG_RISCV_ISA_A) := $(riscv-march-y)a

# 3. Floating Point (Requires both march and mabi updates)
riscv-march-$(CONFIG_RISCV_ISA_F) := $(riscv-march-y)f
riscv-mabi-$(CONFIG_RISCV_ISA_F)  := $(riscv-mabi-y)f

riscv-march-$(CONFIG_RISCV_ISA_D) := $(riscv-march-y)d
# If 'D' is enabled, replace the 'f' in the ABI string with 'd'
riscv-mabi-$(CONFIG_RISCV_ISA_D)  := $(patsubst %f,%d,$(riscv-mabi-y))

# 4. Remaining Extensions
riscv-march-$(CONFIG_RISCV_ISA_C) := $(riscv-march-y)c
riscv-march-$(CONFIG_RISCV_ISA_V) := $(riscv-march-y)v

# 5. Export to Global Compiler Flags
ARCH_CFLAGS := -march=$(riscv-march-y) -mabi=$(riscv-mabi-y) -mcmodel=medany

$(info "ARCH_CFLAGS: $(ARCH_CFLAGS)")
CFLAGS += $(ARCH_CFLAGS)
AFLAGS += $(ARCH_CFLAGS)

