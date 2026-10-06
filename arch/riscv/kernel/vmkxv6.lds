ENTRY(_start)

SECTIONS
{
    . = 0x80200000;

    .text : {
        *(.text.boot)        /* Put _start at 0x80200000 */
        *(.text .text.*)
    }

    .rodata : { *(.rodata .rodata.*) }

    .data : {
        PROVIDE(__global_pointer$ = . + 0x800);
        *(.data .data.*)
    }

    .bss : {
        PROVIDE(_bss_start = .);
        *(.bss.stack)
        *(.bss .bss.*)
        PROVIDE(_bss_end = .);
    }
}