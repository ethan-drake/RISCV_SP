.data
	#bubble sort items
	.word 4
	.word 2
	.word 5
	.word 3
	.word 1
	#selection sort items
	.word 4
	.word 2
	.word 5
	.word 3
	.word 1
.text
addi ra, zero, 0x1
addi sp, zero, 0x2
addi gp, zero, 0x3
addi tp, zero, 0x4
addi t0, zero, 0x5
addi t1, zero, 0x6
addi t2, zero, 0x7
addi s0, zero, 0x8
addi s1, zero, 0x9
addi a0, zero, 0xa
addi a1, zero, 0xb
addi a2, zero, 0xc
addi a3, zero, 0xd
addi a4, zero, 0xe
addi a5, zero, 0xf
addi a6, zero, 0x10
addi a7, zero, 0x11
addi s2, zero, 0x12
addi s3, zero, 0x13
addi s4, zero, 0x14
addi s5, zero, 0x15
addi s6, zero, 0x16
addi s7, zero, 0x17
addi s8, zero, 0x18
addi s9, zero, 0x19
addi s10, zero, 0x1a
addi s11, zero, 0x1b
addi t3, zero, 0x1c
addi t4, zero, 0x1d
addi t5, zero, 0x1e
addi t6, zero, 0x1f

#Bubble sort & selection sort
add zero, zero, zero 	#nop
add t6, tp, zero	#$31 = 4
lui gp, 0x10010		#lui for aligning ai to mem address

mul sp, t0, t6		# ak = 4 * num of items
add sp, sp, gp		# ak memory aligment
begin:add zero, zero, zero 	#nop

lui gp, 0x10010		#lui for aligning ai to mem address
add tp, gp, t6		#aj = ai+4
slt t1, tp, sp		# (aj < ak) ?
beq t1, zero, checker_bubble	#if no, program finishes, goto checker_bubble

load:lw a3, 0(gp)	#mi = M(ai) 
lw a4, 0(tp)		#mj = M(aj)	
slt t1, a4, a3		#(mj < mi) ?
beq t1, zero, skip_swap	#if no, skip swap

sw a4, 0(gp)		#M(ai) = mj //swap
sw a3, 0(tp)		#M(aj) = mi //swap
skip_swap:add gp, gp, t6	#ai = ai+4
add tp, tp, t6		#aj=aj+4

slt t1, tp, sp		# (aj < ak) ?
beq t1, ra, load	#if yes, goto LOAD
sub sp, sp, t6		#ak = ak-4
j begin		#goto begin

checker_bubble:add zero, zero, zero	#nop ***Checker for first 5 items***
lui s10, 0x10010		#lui for aligning addr1 to initial mem address
add s11, s10, t6	#addr2 = addr1 + 4
mul t3, t0, t6		#addr3 = num_of_items * 4

add t3, t3, s10		#addr3 = addr3 + addr1
test_next_data:lw t4, 0(s10)		#maddr1 = M(addr1)
lw t5, 0(s11)		#maddr2 = M(addr2)
slt s9, t5, t4 		#(maddr2 < maddr1) ?

beq s9, zero,next_data 		#if no, proceed to the next data
#add zero, zero, zero		#REMOVE
inf_loop:beq, zero, zero,inf_loop 	#else you're stuck here
next_data:add s10, s10, t6	#addr1 = addr1+4
add s11, s11, t6	#addr2 = addr2 + 4

beq s11, t3, next_program	#if all tested, proceed to the next program
#add zero, zero, zero	#REMOVE
beq zero, zero, test_next_data
next_program: add zero, zero, zero
add zero, zero, zero	#noop

add zero, zero, zero	#nop // initialization for selection sort
add sp, t0, zero	#set min=5
add s1, t0, t6		#$9=9
add a0, s1, ra		#$10=10
add t1, zero, zero	#slt_result=0
add gp, t0, zero	#i=5
add tp, gp, ra		#j=i+1 //selection sort starts here
selection_sort_cont:mul a3, gp, t6		#ai=i*4

lui s0, 0x10010		#initializing base mem address
add a3, a3, s0		# adding to get 0x10010014
lw s7, 0(a3)		#mi = M(ai)
add a2, a3, zero	#amin = ai
add s6, s7, zero	#mmin = mi
mmin__mi:mul a4, tp, t6		#aj = j*4

add a4, a4, s0		#adding to get a4 mem allocation
lw s8, 0(a4)		#mj = M(aj)
slt t1, s8, s6		#(mj < mmin)
beq t1, zero, j_plus_plus		#if(no)
add a2, a4, zero		#amin = aj

add s6, s8, zero	#mmin = mj
j_plus_plus:add tp, tp, ra		#j++
beq tp, a0, j_equal_10 
#add zero, zero, zero	#REMOVE
beq zero, zero, mmin__mi	#if(no)

j_equal_10:add zero, zero, zero	#nop
sw s6, 0(a3)		#M(ai) = mmin //swap
sw s7, 0(a2)		#M(amin) = mi //swap
add gp, gp, ra		#i++

add tp, gp, ra		#j = i+1
beq gp, s1, i_equal_9	#(i==9)
#add zero, zero, zero	#REMOVE

beq zero, zero, selection_sort_cont 	#if(no)
i_equal_9:add zero, zero, zero	#nop

add zero, zero, zero	#***CHECKER FOR THE NEXT 5 ITEMS
mul s10, t0, t6		#index_1#addr1 = num_of_items * 4
add s11, s10, t6	#index_2#addr2 = addr1 + 4
mul t3, t0, t6		#index_3#addr3 = num_of_items * 4

add t3, t3, s10		#index_3#addr3 = addr3 + addr1

next_data_2:add a5, s10, s0		#address 1 calculated from index_1 and base address
lw t4, 0(a5)		#maddr1 = M(addr1)
add a6, s11, s0		#address 2 calculated from index_2 and base address
lw t5, 0(a6)		#maddr2 = M(addr2)
slt s9, t4, t5		#(maddr1 < maddr2) ?

beq s9, ra, maddr1_less_than_maddr2	#if yes, proceed to the next data
#add zero, zero, zero	#REMOVE

inf_loop_2:beq zero, zero inf_loop_2	#else, youre stuck here
maddr1_less_than_maddr2: add s10, s10, t6	#addr1 = addr1+4
add s11, s11, t6	#addr2 = addr2 + 4

beq s11, t3, all_tested	#if all tested, proceed to the next program
#add zero, zero, zero	#REMOVE

beq zero, zero, next_data_2 	#else test next data
all_tested: add zero, zero, zero	#nop
add zero, zero, zero	#nop

add zero, zero, zero	#Programa 2
lui t6, 0x10010	#set base mem address
addi tp, zero, 0x4	#setup $4 to 4
addi a1, zero, 0x9	#set limit to 10 elements (counting 0)
add t5, a4, tp	#set $30 to mem location 11
add a0, zero, zero
lw sp, 0(t6)	#Content of mem location goes to $2
LOOP:beq a0, a1, GOTO2	#track 10 numbers
add t6, t6, tp 	#Increment $31 by 4 so it can point to the next memory
lw gp, 0(t6)	#Content of memory location 2 goes to $3
slt t0, gp, sp	#check if $3 < $2
add a0, a0, ra	#incroment counter $10
beq t0, ra, GOTO1	#if $3 < $2 then
j LOOP		#if $3 > $2 then
GOTO1:add sp, gp, zero	#Move ($3) --> ($2) if $3 < $2
j LOOP
GOTO2:sw sp, 0(t5) #store ($2) at memory location 11
add a6, t5, tp	#set register 16 with mem location 12
lw t1, 0(a6)	#content of memory location 12 goes to $6 --> this branch is never taken
beq sp, t1,LOOP 	#IF $2 = $6 then this branch is always taken
end:j end





