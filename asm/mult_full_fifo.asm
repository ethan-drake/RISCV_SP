#TEST 3
addi t1, zero, 0x1e
addi t2, zero, 0x3
mul a0, t1,t2
mul a1, t1,t2
mul a2, a1,t2
mul a3, a2,t2
mul a4, a3,t2
mul a3, a4,t2
mul a4, t1,t2
fin: j fin
