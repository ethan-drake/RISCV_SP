#TEST 7
addi t1, zero, 0x2C
lui t2, 0x10010
addi t0, t2,4
sw t1,0x0(t0)
sw t1,0x0(t2)
lw a0,0x0(t0)
lw a1,0x0(t2)
fin: j fin
