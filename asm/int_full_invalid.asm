addi t1, zero, 0x2C
lui t2, 0x10010
sw t1,0x0(t2)
lw a0,0x0(t2)
add a1,t1,a0
add a2,t1,a0
add a3,t1,a0
add a4,t1,a0
add a5,t1,a0
fin: j fin
