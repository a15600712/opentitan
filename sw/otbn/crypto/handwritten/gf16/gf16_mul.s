/*gf16_mul.s*/
/*
Define a gf16 multiply function 
using 256 bit WRD
*/
.align 4

.section .data
    qword_msb:
        .word 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888, 0x88888888


.section .text
.global gf16_mul

/*
@param[out]  w0: ( Result = a * b)
@param[in]   w1: ( input a ) 64 gf16 element (256bits)
@param[in]   w2: ( input b )  1 gf16 element (256bits)
w3: msb_mask
w4: a_msb
w5: 
w6: 
w7:
w8: 
w27: one
w28: temp
w29: temp
w30: zeros
w31: temp
*/

gf16_mul:
    /*Set up msb_mask in w3*/
    la x5, qword_msb
    li x6, 3
    bn.lid x6, 0(x5)       

    /*w31= b & 1*/
    bn.addi w27, w27, 1 /*{temp} w31 = 1 */
    bn.and w31, w2, w27 /*{temp} w31 = {1} w31 & {b} w2*/
    
    /*w0 = a * (w31)*/
    bn.mulqacc.wo.z   w0, w1.0, w31.0, 0  /* {Result} w0 = w31 * {a} w1.q0[63-0]*/
    bn.mulqacc.wo.z   w0, w1.1, w31.0, 64
    bn.mulqacc.wo.z   w0, w1.2, w31.0, 128
    bn.mulqacc.wo.z   w0, w1.3, w31.0, 192

    /*a_msb = mask_msb & {a} w1*/
    bn.and w4, w3, w1 

    bn.xor w1, w1, w4 /*{cleared MSB a} w1 = {a} w1[255-0] & {a_msb} w4[255-0] */


    /*w1 = a << 1*/
    bn.rshi w1, w1, w30 >> 255  /* ( w1 || zeros ) >> 255 equivalent to w1 << 1*/
    
    /*w4 = a_msb >> 3*/
    bn.rshi w4, w30, w4 >> 3    /* ( zeros || w4 ) >> 3 equivalent to w4 >> 3*/

    /* w29 = 3*/
    bn.addi w29, w30, 3 

    /*w31 = w4 * w29 */
    bn.mulqacc.z    w4.0, w29.0, 0          
    bn.mulqacc.so   w31.l, w4.1, w29.0, 64  
    bn.mulqacc      w4.2, w29.0, 0          
    bn.mulqacc.so   w31.u, w4.3, w29.0, 64  


    /*w1 = (a<<1) ^ ((a_msb >> 3) * 3)*/
    bn.xor w1, w1, w31 

    /*w31 = b >> 1*/
    bn.rshi w31, w30, w2 >> 1 /*w31 = ( w30 || w2 ) >> 1*/
    /*w29 = 1*/
    bn.addi w29, w30, 1 /* {temp} w29 = {zeros} w30 + 1*/
    /*w31 = w31 & w29*/
    bn.and w31, w29, w31

    /*w29 = (a64) * ((b32 >> 1) & 1)*/
    bn.mulqacc.z    w1.0, w31.0, 0          
    bn.mulqacc.so   w29.l, w1.1, w31.0, 64  
    bn.mulqacc      w1.2, w31.0, 0          
    bn.mulqacc.so   w29.u, w1.3, w31.0, 64  

    /*w0 = w0 ^ w29*/
    bn.xor w0, w0, w29

    bn.and w4, w3, w1
    bn.xor w1, w1, w4
    bn.rshi w1, w1, w30 >> 255
    bn.rshi w4, w30, w4 >> 3

    bn.addi w29, w30, 3

    bn.mulqacc.z    w4.0, w29.0, 0          
    bn.mulqacc.so   w31.l, w4.1, w29.0, 64  
    bn.mulqacc      w4.2, w29.0, 0          
    bn.mulqacc.so   w31.u, w4.3, w29.0, 64  
    bn.xor w1, w1, w31 

    bn.rshi w31, w30, w2 >> 2
    bn.addi w29, w30, 1

    bn.and w31, w29, w31

    bn.mulqacc.z    w1.0, w31.0, 0          
    bn.mulqacc.so   w29.l, w1.1, w31.0, 64  
    bn.mulqacc      w1.2, w31.0, 0          
    bn.mulqacc.so   w29.u, w1.3, w31.0, 64  

    bn.xor w0, w0, w29

    bn.and w4, w3, w1
    bn.xor w1, w1, w4
    bn.rshi w1, w1, w30 >> 255
    bn.rshi w4, w30, w4 >> 3

    bn.addi w29, w30, 3

    bn.mulqacc.z    w4.0, w29.0, 0          
    bn.mulqacc.so   w31.l, w4.1, w29.0, 64  
    bn.mulqacc      w4.2, w29.0, 0          
    bn.mulqacc.so   w31.u, w4.3, w29.0, 64  
    bn.xor w1, w1, w31 

    bn.rshi w31, w30, w2 >> 3
    bn.addi w29, w30, 1

    bn.and w31, w29, w31

    bn.mulqacc.z    w1.0, w31.0, 0          
    bn.mulqacc.so   w29.l, w1.1, w31.0, 64  
    bn.mulqacc      w1.2, w31.0, 0          
    bn.mulqacc.so   w29.u, w1.3, w31.0, 64  

    bn.xor w0, w0, w29



    ret





