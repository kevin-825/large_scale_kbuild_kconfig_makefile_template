

/* kernel/main.c */
#include <stdint.h>
#include "printk.h"

void kmain(uint64_t hartid, uint64_t dtb_ptr)
{
    /* Initialize drivers, memory management, and interrupt controllers */
    printk("Hello, xv6 kernel!\n");
    printk("hartid: %d, dtb_ptr: 0x%lx\n", hartid, dtb_ptr);
    while (1) {
        asm volatile("wfi");
    }
}