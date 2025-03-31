/*new_matvec_mul.s*/
/*
.section .data
.balign 32
accumulator:
    .word 0x0, 0x0, 0x0, 0x0
    .word 0x0, 0x0, 0x0, 0x0
    .word 0x0, 0x0, 0x0, 0x0
    .word 0x0, 0x0, 0x0, 0x0
    
.balign 32
matrixA:
    .word 0x22222222, 0x22222222, 0x22222222, 0x22222222
    .word 0x22222222, 0x22222222, 0x22222222, 0x22222222
    .word 0x11111111, 0x11111111, 0x11111111, 0x11111111
    .word 0x11111111, 0x11111111, 0x11111111, 0x11111111

    
    .word 0x22222222, 0x22222222, 0x22222222, 0x22222222
    .word 0x22222222, 0x22222222, 0x22222222, 0x22222222
    .word 0x11111111, 0x11111111, 0x11111111, 0x11111111
    .word 0x11111111, 0x11111111, 0x11111111, 0x11111111

    
.balign 4
n_A_byte:
    .word 0x40 
.balign 4
n_A_width:
    .word 0x2
.balign 32
vectorB:
    .word 0x21
*/
.section .text
.balign 4  
.global _gf16matvec_mul
/*
x2:accumulator
x3:matrixA
x4:n_A_byte
x7:n_A_width
x8:vectorB
x9: use for load vectorB
w5:vectorB
w6:vecB_mask for LSB
w7:accumulator
*/

_gf16matvec_mul:
    /*make sure w31 is zero*/
	bn.xor w31, w31, w31
    /*make sure register for accumulator is zero */
    bn.xor w7, w7, w7
    /*x2:accumulator*/
    /*la x2, accumulator*/
    la x2, 0x20

    /*x3:matrixA*/
    /*la x3, matrixA*/
    la x3, 0x60

    /*x4:n_A_byte*/
    /*la x4, n_A_byte
    lw x4, 0(x4)*/
    la x4, 0xE0
    lw x4, 0(x4)

    /*x7:n_A_width*/
    /*
    la x7, n_A_width
    lw x7, 0(x7)
    */
    la x7, 0xE4
    lw x7, 0(x7)

    /*x8:vectorB*/
    /*la x8, vectorB*/
    la x8, 0x100

    /*w5:vectorB*/
	addi x9,x0,5
	bn.lid x9, 0(x8)


    /*w6:vecB_mask*/
    bn.addi w6,w31,0xf

    /*x10:w1*/
    addi x10,x0,1
    /*Initialize counter for elements in current register*/
    xor x13, x13, x13
    /*Elements per 256-bit register (64 × 4-bit elements)*/
    addi x14, x0, 64


    loop x7, 21
        
        /*x11:(temp)n_A_byte{x4}*/
        add x11,x0,x4
        /*select LSB from w5 then store into w2*/
        bn.and w2, w5, w6
        /*x12:w7*/
        addi x12, x0, 7
        A_vecbyte_mul:
            /*Jump out loop when x11 == 0*/
            beq x11,x0, A_vecbyte_mul_done

            /*load matrixA into w1 then x3+=32*/
            bn.lid x10, 0(x3++)
            jal x1, gf16_mul
            /*load accumulator then XOR with gf16 result*/
            bn.lid x12, 0(x2)
            bn.xor w7,w7,w0

            /*store w7 into x2*/
            bn.sid x12, 0(x2)
            /*x2 move to next address x2+=32*/
            addi x2, x2, 32

            /*
              Each iter process 32bytes 
              x11 contain how many left
            */
            addi x11, x11, -32
            bne x11,x0, A_vecbyte_mul
            
        A_vecbyte_mul_done:

        bn.rshi w5, w31, w5 >> 4
        /*la x2, accumulator*/
        la x2, 0x20
        addi x13,x13,1
        
        bne x13,x14,skip_load_next_vecB
            addi x8,x8,32
            bn.lid x9, 0(x8)
            xor x13, x13, x13
        skip_load_next_vecB:

    NOP

    ecall





