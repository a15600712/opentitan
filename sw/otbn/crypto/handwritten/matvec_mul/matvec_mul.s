
.section .data
.balign 32
matrixA:
	.word 0x03020100, 0x07060504
	.word 0x0B0A0908, 0x0F0E0D0C
	.word 0x03020100, 0x07060504
	.word 0x0B0A0908, 0x0F0E0D0C

	.word 0xaaaaaaaa, 0xbbbbbbbb
	.word 0x0B0A0908, 0x0F0E0D0C
	.word 0x03020100, 0x07060504
	.word 0x0B0A0908, 0x0F0E0D0C
.balign 32
vectorB:
	.word 0x12345671,0,0,0,0,0,0,0
.balign 32
n_A_width:
	.word 0x8,0,0,0,0,0,0,0
.balign 32
n_A_vec_byte:
	.word 0x20,0,0,0,0,0,0,0



.section .text
.global _gf16matvec_mul
_gf16matvec_mul:
	
	/*x5 = n_A_width*/
	la x5, n_A_width
	lw x5, 0(x5)

	/*x31 as index to select element in vectorB*/
	xor x31, x31, x31

	/*w1 MatrixA */
	la x29, matrixA
	addi x30, x0, 1
	bn.lid x30, 0(x29)

	/*w26 vectorB */
	la    x6, vectorB
	addi  x7, x0, 26
	bn.lid x7, 0(x6)
	
	bn.mov w2,w26
	bn.addi w3, w31, 0xf
	bn.and w2, w2,w3

	jal x1, gf16_mul

	ecall