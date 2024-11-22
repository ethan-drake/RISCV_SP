inicio:addi t0, zero, 0x4
lui a7, 0x10010
sw t0, 4(a7)
addi t1, zero, 0x1e
addi t2, zero, 0x3
beq t0,zero,inicio#branch not taken
add t0,t1,t2
addi a0, zero, 0x2
lw a6, 4(a7)
mul a1,t0,t2
div a2,t1,t2
beq t1,t1,salto#branch taken
or t2,t0,t2
salto:and s0,t0,t1 
fin: j fin 
#TEST 1