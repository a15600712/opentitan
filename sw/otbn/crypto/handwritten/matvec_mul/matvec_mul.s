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
	/*w5:vectorB*/
	addi x3,x0,5
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