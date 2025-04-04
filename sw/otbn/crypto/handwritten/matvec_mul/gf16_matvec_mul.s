/*gf16_matvec_mul.s*/

.section .text
.balign 4  
/*
x10:accumulator
x11:matrixA
x12:n_A_byte
x13:n_A_width
x14:vectorB
x31,x30,x29,x28,x27,x7,x4:tmp
w5:vectorB
w6:vecB_mask for LSB
w7:accumulator
*/

.global gf16_matvec_mul
gf16_matvec_mul:

    bn.xor w31, w31, w31
    add x4, x0, x10
    /*x12:n_A_byte*/
    lw x12, 0(x12)
    /*x13:n_A_width*/
    lw x13, 0(x13)


    /*w5:vectorB*/
	addi x27,x0,5
	bn.lid x27, 0(x14)


    /*w6:vecB_mask*/
    bn.addi w6,w31,0xf

    /*x31:w1*/
    addi x31,x0,1
    /*Initialize counter for elements in current register*/
    xor x28, x28, x28
    /*Elements per 256-bit register (64 × 4-bit elements)*/
    addi x7, x0, 64


    loop x13, 21
        
        /*x30:(temp)n_A_byte{x12}*/
        add x30,x0,x12
        /*select LSB from w5 then store into w2*/
        bn.and w2, w5, w6
        /*x29:w7*/
        addi x29, x0, 7
        A_vecbyte_mul:
            /*Jump out loop when x30 == 0*/
            beq x30,x0, A_vecbyte_mul_done

            /*load matrixA into w1 then x11+=32*/
            bn.lid x31, 0(x11++)
            jal x1, gf16_mul
            /*load accumulator then XOR with gf16 result*/
            bn.lid x29, 0(x4)
            bn.xor w7,w7,w0

            /*store w7 into x4*/
            bn.sid x29, 0(x4)
            /*x4 move to next address x4+=32*/
            addi x4, x4, 32

            /*
              Each iter process 32bytes 
              x30 contain how many left
            */
            addi x30, x30, -32
            bne x30,x0, A_vecbyte_mul
            
        A_vecbyte_mul_done:

        bn.rshi w5, w31, w5 >> 4
        /*mov x4, accumulator*/
        add x4, x0, x10
        addi x28,x28,1
        
        bne x28,x7,skip_load_next_vecB
            addi x14,x14,32
            bn.lid x27, 0(x14)
            xor x28, x28, x28
        skip_load_next_vecB:

    NOP

    ret





