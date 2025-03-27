/*gf16_mul.s*/
/*
Define a gf16 multiply function 
using 256 bit WRD
*/
.section .data
.balign 32
qword_msb:
.word 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888
.section .text
.balign 4
.global gf16_mul
/*
x5,x6 will be used
@param[out]  w0: ( Result = a * b)
@param[in]   w1: ( input a ) 64 gf16 element (256bits)
@param[in]   w2: ( input b )  1 gf16 element (256bits)
w3: msb_mask
w4: a_msb 
w27: one
w28: temp
w29: temp
w30: temp
w31: zeros
*/

gf16_mul:

    /*make sure w31 is zero*/
    bn.xor w31, w31, w31
    bn.xor w0, w0, w0
    la x5, qword_msb
    li x6, 3
    bn.lid x6, 0(x5)  
    /*w30= b & 1*/

    bn.addi w27, w31, 1 /*{temp} w27 = 1 */
    bn.and w30, w2, w27 /*{temp} w30 = {1} w30 & {b} w2*/
    /*w0 = a * (w30)*/
    
    bn.mulqacc.z    w1.0, w30.0, 0  /* {Result} w0 = w30 * {a} w1.q0[63-0]*/
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w0, w1.3, w30.0, 192

    /*a_msb = mask_msb & {a} w1*/
    bn.and w4, w3, w1 

    bn.xor w1, w1, w4 /*{cleared MSB a} w1 = {a} w1[255-0] & {a_msb} w4[255-0] */


    /*w1 = a << 1*/
    bn.rshi w1, w1, w31 >> 255  /* ( w1 || zeros ) >> 255 equivalent to w1 << 1*/
    
    /*w4 = a_msb >> 3*/
    bn.rshi w4, w31, w4 >> 3    /* ( zeros || w4 ) >> 3 equivalent to w4 >> 3*/

    /* w29 = 3*/
    bn.addi w29, w31, 3 
    /*w30 = w4 * w29 */


    bn.mulqacc.z    w4.0, w29.0, 0
    bn.mulqacc      w4.1, w29.0, 64
    bn.mulqacc      w4.2, w29.0, 128
    bn.mulqacc.wo   w30, w4.3, w29.0, 192

    bn.xor w1, w1, w30 
    /*w1 = (a<<1) ^ ((a_msb >> 3) * 3)*/
    /*w30 = b >> 1*/

    bn.rshi w30, w31, w2 >> 1 /*w30 = ( w31 || w2 ) >> 1*/
    /*w29 = 1*/
    /*w30 = w30 & w29*/
    bn.addi w29, w31, 1 /* {temp} w29 = {zeros} w31 + 1*/
    bn.and w30, w29, w30

    /*w29 = (a64) * ((b32 >> 1) & 1)*/
    bn.mulqacc.z    w1.0, w30.0, 0          
    bn.mulqacc      w1.1, w30.0, 64  
    bn.mulqacc      w1.2, w30.0, 128          
    bn.mulqacc.wo    w29, w1.3, w30.0, 192  

    /*w0 = w0 ^ w29*/
    bn.xor w0, w0, w29

    bn.and w4, w3, w1
    bn.xor w1, w1, w4
    bn.rshi w1, w1, w31 >> 255
    bn.rshi w4, w31, w4 >> 3

    bn.addi w29, w31, 3

    bn.mulqacc.z    w4.0, w29.0, 0          
    bn.mulqacc      w4.1, w29.0, 64  
    bn.mulqacc      w4.2, w29.0, 128 
    bn.mulqacc.wo   w30,w4.3, w29.0, 192
    

    bn.xor w1, w1, w30 
    bn.rshi w30, w31, w2 >> 2

    bn.addi w29, w31, 1
    bn.and w30, w29, w30

    bn.mulqacc.z    w1.0, w30.0, 0          
    bn.mulqacc      w1.1, w30.0, 64  
    bn.mulqacc      w1.2, w30.0, 128         
    bn.mulqacc.wo   w29, w1.3, w30.0, 192

    bn.xor w0, w0, w29

    bn.and w4, w3, w1
    bn.xor w1, w1, w4
    bn.rshi w1, w1, w31 >> 255
    bn.rshi w4, w31, w4 >> 3

    bn.addi w29, w31, 3

    bn.mulqacc.z    w4.0, w29.0, 0          
    bn.mulqacc      w4.1, w29.0, 64  
    bn.mulqacc      w4.2, w29.0, 128  
    bn.mulqacc.wo     w30,w4.3, w29.0, 192          
    bn.xor w1, w1, w30 
    bn.rshi w30, w31, w2 >> 3

    bn.addi w29, w31, 1
    bn.and w30, w29, w30

    bn.mulqacc.z    w1.0, w30.0, 0          
    bn.mulqacc      w1.1, w30.0, 64  
    bn.mulqacc      w1.2, w30.0, 128      
    bn.mulqacc.wo   w29, w1.3, w30.0, 192  

    bn.xor w0, w0, w29
    ret
