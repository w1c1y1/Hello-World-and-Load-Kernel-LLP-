ENTRY(booting)

SECTIONS {
    . = 0x7C00;

    .boot : { *(.boot) }

    . = 0x7E00;

    .kernel : {
        *(.text);
        *(.rodata);
        *(.rodata.*);
        *(.data);
        *(.bss);
    }


    /DISCARD/ : {
        *(.eh_frame)
        *(.note.*)
        *(.comment)
    }
}