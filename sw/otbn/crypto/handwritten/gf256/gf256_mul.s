/*gf256_mul.s */
/*
Define a gf256 multiply function 
using 256 bit WRD
 */
.align 4

.section .data
    qword_msb:
        .word 0x80808080, 0x80808080, 0x80808080, 0x80808080, 0x80808080, 0x80808080, 0x80808080, 0x80808080


.section .text
/*
@param[out]  w0: ( Result = a * b)
@param[in]   w1: ( input a ) 32 gf256 element (256bits)
@param[in]   w2: ( input b )  1 gf16 element (256bits)
w3: msb_mask
w4: a_msb
w5: 
w6: 
w7:
w8: 
w27: temp
w28: temp
w29: temp
w30: temp
w31: zeros
*/
.global gf256_mul


gf256_mul:
    /*Set up msb_mask in w3 */
    la x5, qword_msb
    li x6, 3
    bn.lid x6, 0(x5)       

    /*w30 = 1*/
    bn.addi w30, w31, 1
    /*w30 = b & 1*/
    bn.and w30, w2, w30
 
    
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w0, w1.3, w30.0, 192


    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 1*/
    bn.rshi w30, w31, w2 >> 1
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 1) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29


    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 2*/
    bn.rshi w30, w31, w2 >> 2
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 2) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29



    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 3*/
    bn.rshi w30, w31, w2 >> 3
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 3) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29


    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 4*/
    bn.rshi w30, w31, w2 >> 4
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 4) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29


    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 5*/
    bn.rshi w30, w31, w2 >> 5
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 5) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29


    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 6*/
    bn.rshi w30, w31, w2 >> 6
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 6) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29


    /*{a_msb} w4 = {a} w1 & {msb_msk} w3 */
    bn.and w4, w1, w3
    /*{msb_cleared a} w1 = {a} w1 ^ {a_msb} w4 */
    bn.xor w1, w1, w4
    /* w30 = a_msb >> 7*/
    bn.rshi w30, w31, w4 >> 7
    /*w29 = 0x1b*/
    bn.addi w29, w31, 0x1b
    /*w28 = {(a_msb >> 7)} w30 * {0x1b} w29 */
    bn.mulqacc.z    w30.0, w29.0, 0
    bn.mulqacc      w30.1, w29.0, 64
    bn.mulqacc      w30.2, w29.0, 128 
    bn.mulqacc.wo   w28, w30.3, w29.0, 192
    /*{a << 1} w29 = {a||zeros} >> 255 */
    bn.rshi w29, w1, w31 >> 255
    /*w1 = {a64 << 1}w29 ^ {(a_msb >> 7)*0x1b} w28 */
    bn.xor w1, w29, w28
    /*w30 = {zeros||b} >> 7*/
    bn.rshi w30, w31, w2 >> 7
    /*w29 = 1*/
    bn.addi w29, w31, 1
    /*w30 = ( {zeros||b} >> 7) & 1 */
    bn.and w30, w30, w29
    /*w29 = {a} w1 * w30*/
    bn.mulqacc.z    w1.0, w30.0, 0
    bn.mulqacc      w1.1, w30.0, 64
    bn.mulqacc      w1.2, w30.0, 128
    bn.mulqacc.wo   w29, w1.3, w30.0, 192
    /*w0 = w0 ^ w29 */
    bn.xor w0, w0, w29














    ret




