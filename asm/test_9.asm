#TEST 9 update and shift at same time
addi t1, zero, 0x1e
addi t2, zero, 0x3
div a2,t1,t2
addi t0, a2, 0x1e
addi s0, zero, 0x4
addi s1, a2, 0x1a
addi a0, zero, 0x4
addi s7, zero, 0x4
addi a3, s7, 0x1b
addi a4, zero, 0x4
addi a5, a2, 0x6
addi a6,zero, 0x1
addi a7,zero, 0x2
addi s2,zero, 0x3
addi s3,zero, 0x4
addi s4,zero, 0x5
addi s5,zero, 0x6
addi s6,zero, 0x7
fin: jal zero, fin 
