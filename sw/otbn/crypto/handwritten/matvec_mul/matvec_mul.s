
.section .data
.balign 32
matrixA:
	.word 0x03020100, 0x07060504
	.word 0x0B0A0908, 0x0F0E0D0C
	.word 0x03020100, 0x07060504
	.word 0x0B0A0908, 0x0F0E0D0C

	.word 0xaaaaaaaa, 0xbbbbbbbb
	.word 0xcccccccc, 0xdddddddd
	.word 0xeeeeeeee, 0xffffffff
	.word 0x00000000, 0x11111111

	.word 0x22222222, 0x33333333
	.word 0x44444444, 0x55555555
	.word 0x66666666, 0x77777777
	.word 0x88888888, 0x99999999

	.word 0x00000000, 0x11111111
	.word 0xaaaaaaaa, 0xbbbbbbbb
	.word 0xcccccccc, 0xdddddddd
	.word 0xeeeeeeee, 0xffffffff

.balign 32
vectorB:
	.word 0x0010,0,0,0,0,0,0,0
.balign 4
n_A_width:
	.word 0x4
.balign 4
n_A_vec_byte:
	.word 0x20


.section .text
.balign 4
.global _gf16matvec_mul
_gf16matvec_mul:

	/*w31 zero*/
	bn.xor w31, w31, w31

	/*x5 = n_A_width*/
	la x5, n_A_width
	lw x5, 0(x5)


	/*prep load matrixA*/
	la x29, matrixA
	addi x30, x0, 1

	bn.xor w26, w26, w26
	/*w26 vectorB */
	la    x6, vectorB
	addi  x7, x0,26
	bn.lid x7, 0(x6)

	/*w25 0xf mask*/
	bn.addi w25, w31, 0xf
	

	/*w5:accum*/
	bn.xor w5, w5, w5
	
	loop x5, 4
		/*w1:MatrixA and increment every iter*/
		bn.lid x30, 0(x29++)
		/*select  LSB for gf16mul*/
		bn.and w2, w25, w26
		bn.rshi w26, w31,w26 >> 4
		/*jal gf16_mul*/
		/*jal x1, gf16_mul
		bn.xor w5,w5,w0*/
	NOP


	ecall