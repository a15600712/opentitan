/* add_sim_test.s */

.align 4
.section .data

val_a:
  /* 256-bit operand: "3" in the lowest word, zeros above. */
  .word 3, 0, 0, 0, 0, 0, 0, 0

val_b:
  /* 256-bit operand: "4" in the lowest word, zeros above. */
  .word 4, 0, 0, 0, 0, 0, 0, 0

result:
  /* 256-bit buffer for the final result. */
  .word 0, 0, 0, 0, 0, 0, 0, 0

.section .text
.globl main
main:
  /* Load val_a into w10 */
  la   x2, val_a /*load val add into x2*/
  li   x3, 10 /*make x3 represent w10*/
  bn.lid x3, 0(x2) /*using bn to load data to w10 Load a WLEN-bit little-endian value from data memory.*/

  /* Load val_b into w11 */
  la   x2, val_b
  li   x3, 11
  bn.lid x3, 0(x2)

  /* Call "add" (in a.s) to do w10 = w10 + w11 */
  jal x1, add

  /* Store w10 back to memory at "result" */
  la   x2, result
  li   x3, 10
  bn.sid x3, 0(x2) /*Store a WDR to memory as a WLEN-bit little-endian value.*/
  
  ecall
  # ret
  