BEGIN:addi t0, zero, 0x9
addi t1, zero, 0x3
beq zero, zero, GOTO1
addi s3, zero, 0x13
GOTO1:addi s4, zero, 0x14
addi s5, zero, 0x15
addi s6, zero, 0x16
LOOP:beq t0, zero, LOOP
addi s7, zero, 0x17
addi s8, zero, 0x18
addi s9, zero, 0x19
LOOP2:beq t0, zero, LOOP2
beq zero, zero, BEGIN