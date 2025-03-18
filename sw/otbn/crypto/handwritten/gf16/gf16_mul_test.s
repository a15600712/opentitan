/*gf16_mul_test.s*/

.section .data
.balign 32
/* 256-bit operand */
val_a:
    .word 0x00000000, 0x11111111
	.word 0xaaaaaaaa, 0xbbbbbbbb
	.word 0xcccccccc, 0xdddddddd
	.word 0xeeeeeeee, 0xffffffff
.balign 32
val_b:
/* 256-bit operand: space for 256 bits (32 bytes) */
    .word 0x1,0,0,0,0,0,0,0

.section .text
.balign 4
.global main
main:
    /* load val_a into w01 */
    la x5, val_a
    li x6, 1
    bn.lid x6, 0(x5)

    /* load val_b into w02 */
    la x5, val_b
    li x6, 2
    bn.lid x6, 0(x5)

    jal x1, gf16_mul

    ecall
