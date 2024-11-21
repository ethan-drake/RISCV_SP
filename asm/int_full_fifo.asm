#TEST 2
addi t1, zero, 0x1e
addi t2, zero, 0x3
div a2,t1,t2
addi t1, a2, 0x1e
addi t2, a2, 0x4
addi t1, a2, 0x1a
addi t2, a2, 0x5
addi t1, a2, 0x1b
addi t2, a2, 0x6
fin: jal zero, fin 
