/* add.s*/
/* Defines a function "add". */
/* This trivial example sets w10 = w10 + w11.*/
.balign 4
.section .text
.globl add
add:
  /* Use an OTBN "big number" add instruction to add w10 + w11 => w10*/
  bn.add w10, w10, w11
  ret
  # ecall
  # so in this situation ecall and ret both are fine