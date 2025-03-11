.align 4
.section .data
/* 256-bit operand*/
val_a:
    .word 0x12345678, 0x9ABCDEF0, 0x12345678, 0x9ABCDEF0, 0x12345678, 0x9ABCDEF0, 0x12345678, 0x9ABCDEF0
val_b:
/* 256-bit operand: "F" in the lowest word, zeros above. */
    .word 0x0000000F, 0, 0, 0, 0, 0, 0, 0


.section .text


.global main
main:
    /*load val_a in to w01*/
    la x5, val_a
    li x6, 1
    bn.lid x6,0(x5)

    /*load val_b in to w02*/
    la x5, val_b
    li x6, 2
    bn.lid x6,0(x5)

    jal x1, gf16_mul

    ecall
