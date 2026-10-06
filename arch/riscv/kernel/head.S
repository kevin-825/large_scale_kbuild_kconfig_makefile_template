/*
 * arch/riscv/kernel/head.S
 *
 * Early entry point for kxv6 kernel execution.
 */

#define BOOT_STACK_SIZE 4096

.section .text.boot, "ax"
.global _start
.type _start, @function

_start:
    /* Disable interrupts at startup */
    csrw    sstatus, zero

    /* Park secondary HARTs (hartid != 0) until SMP initialization */
    bnez    a0, .Lsecondary_park

    /* Initialize Global Pointer for GNU relaxation optimization */
.option push
.option norelax
    la      gp, __global_pointer$
.option pop

    /* Set up initial boot stack pointer */
    la      sp, boot_stack_top

    /* Preserve SBI parameters across BSS clearing */
    mv      s0, a0                      /* s0 = hartid */
    mv      s1, a1                      /* s1 = dtb_ptr */

    /* Clear the .bss section */
    la      t0, _bss_start
    la      t1, _bss_end
.Lclear_bss_loop:
    bgeu    t0, t1, .Lclear_bss_done
    sd      zero, 0(t0)
    addi    t0, t0, 8
    j       .Lclear_bss_loop

.Lclear_bss_done:
    /* Restore C arguments (a0 = hartid, a1 = dtb_ptr) */
    mv      a0, s0
    mv      a1, s1

    /* Jump to C kernel entry point */
    tail    kmain

/* Spin loop for secondary HARTs */
.Lsecondary_park:
    wfi
    j       .Lsecondary_park

.size _start, . - _start

/* Boot stack allocation */
.section .bss.stack, "aw", @nobits
.align 12                               /* 4KB alignment */
.global boot_stack
boot_stack:
    .space BOOT_STACK_SIZE
.global boot_stack_top
boot_stack_top: