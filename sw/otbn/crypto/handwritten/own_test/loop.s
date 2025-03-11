.section .data
.balign 4
matrixA:
.word 0x03020100, 0x07060504
.word 0x0B0A0908, 0x0F0E0D0C
.word 0x03020100, 0x07060504
.word 0x0B0A0908, 0x0F0E0D0C
.word 0xaaaaaaaa, 0xbbbbbbbb
.word 0x0B0A0908, 0x0F0E0D0C
.word 0x03020100, 0x07060504
.word 0x0B0A0908, 0x0F0E0D0C
vectorB:
.word 0x12345678,0,0,0,0,0,0,0
n_A_width:
.word 0x2,0,0,0,0,0,0,0

.section .text
.global test_loop
test_loop:
    /* Load the width into x5 */
    la x5, n_A_width
    lw x5, 0(x5)
    
    /* Initialize matrix address and destination register */
    la x28, matrixA
    addi x29, x0, 1

    loop x5, 1
        bn.lid x29, 0(x28++)




    ecall