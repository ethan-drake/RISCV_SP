addi t1, zero, 0x1e 
addi t2, zero, 0x3
div a2,t1,t2
addi t0, a2, 0x1e
mul a1,a2,t2
div a3, t1, t2
addi s1, a2, 0x1a
addi a0, a2, 0x4
addi s7, a2, 0x4
fin: jal zero, fin 
#TEST 10: More that one ready at the same time for the  issue unit