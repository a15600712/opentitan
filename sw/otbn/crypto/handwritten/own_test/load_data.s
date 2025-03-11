.balign 4
.section .data
val_scalar:
    .word 0x11223344, 0x55667788, 0x99AABBCC, 0xDDEEFF00
.balign 32
val_wide:
    .word 0x12345678, 0x9ABCDEF0, 0xDEADBEEF, 0xCAFEBABE
    .word 0x0BADF00D, 0xFEEDFACE, 0x11223344, 0x55667788

.section .text
.globl _start
_start:
    # Load scalar values using lw (aligned to 4 bytes)
    la x3, val_scalar   # Load base address of val_scalar
    lw x4, 0(x3)        # Load first word: 0x11223344
    lw x5, 4(x3)        # Load second word: 0x55667788
    lw x6, 8(x3)        # Load third word: 0x99AABBCC
    lw x7, 12(x3)       # Load fourth word: 0xDDEEFF00

    # Load wide register using bn.lid (aligned to 32 bytes)
    la x10, val_wide   # Load base address of val_wide
		li x11, 0
    bn.lid x11, 0(x10)  # Load 256-bit (8 words) into w0

    # Exit simulation
    ecall
