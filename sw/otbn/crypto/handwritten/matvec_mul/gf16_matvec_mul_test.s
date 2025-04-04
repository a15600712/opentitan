/*gf16_matvec_mul_test.s*/

.section .data
.balign 32
accumulator:
    .zero 2048 /* Reserve 2048 bytes for 4096 4-bit results*/
.balign 32
matrixA:
    .zero 196608 /* Reserve 196608 bytes for matrix data*/
.balign 4
n_A_byte:
    .word 2048 /* 0x00000800 - Size of one column in bytes*/
.balign 4
n_A_width:
    .word 96   /* 0x00000060 - Number of columns  vector B elements*/
.balign 32
vectorB:
    .zero 64 /* Reserve 64 bytes for vector B data*/

.section .text
.balign 4  
/*
@param[in][out] x10:accumulator
@param[in] x11:matrixA
@param[in] x12:n_A_byte
@param[in] x13:n_A_width
@param[in] x14:vectorB
*/

.global main
main:
    /*x10:accumulator*/
    la x10, accumulator

    /*x11:matrixA*/
    la x11, matrixA

    /*x12:n_A_byte*/
    la x12, n_A_byte

    /*x13:n_A_width*/
    la x13, n_A_width

    /*x14:vectorB*/
    la x14, vectorB

    jal x1, gf16_matvec_mul

    

    ecall





