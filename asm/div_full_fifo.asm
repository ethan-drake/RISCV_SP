#TEST 4
addi t1, zero, 0x2C
addi t2, zero, 0x4
div a0, t1,t2
div a1, a0,t2
div a2, a1,t2
div a3, a2,t2
div a4, a3,t2
div a3, t1,t2
div a4, t1,t2
fin: j fin
