
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
	.word 0x2222,0,0,0,0,0,0,0
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
	/*make sure w31 is zero*/
	bn.xor w31, w31, w31
	/*x2:address matrixA*/
	la x2, matrixA
	/*x4:address vectorB*/
	la x4, vectorB
	addi x3,x0,5
	/*w5:vectorB*/
	bn.lid x3, 0(x4)
	
	la x7, n_A_width
	lw x7, 0(x7)
	addi x3,x0,1

	bn.addi w6,w31,0xf
	
	loop x7,5
		bn.lid x3, 0(x2++)
		bn.and w2, w5, w6
		bn.rshi w5, w31, w5 >> 4
		jal x1, gf16_mul
		bn.xor w7, w7, w0
	NOP
	
	ecall