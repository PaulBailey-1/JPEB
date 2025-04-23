	movi r3 main
	jalr r0  r3 

# Data Section:

# Code Section:
collatz:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -9
	sw r3  r2  -1
	movi r3 1
	sw r3  r2  -2
	lw r3  r2  -1
	lw r4  r2  -2
	and r3  r3  r4 
	sw r3  r2  -3
	lw r3  r2  -3
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 collatz.else.6
	jalr r0  r3 
	lw r3  r2  -1
	lw r4  r2  -1
	add r3  r3  r4 
	sw r3  r2  -4
	lw r3  r2  -4
	lw r4  r2  -1
	add r3  r3  r4 
	sw r3  r2  -5
	movi r3 1
	sw r3  r2  -6
	lw r3  r2  -5
	lw r4  r2  -6
	add r3  r3  r4 
	sw r3  r2  -7
	lw r3  r2  -7
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
	movi r3 collatz.end.9
	jalr r0  r3 
collatz.else.6:
	movi r3 1
	sw r3  r2  -8
	lw r3  r2  -1
	lw r4  r2  -8
	call right_shift
	sw r3  r2  -9
	lw r3  r2  -9
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
collatz.end.9:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
main:
	movi r1 40959
	movi r2 40959
	addi r1  r1  -11
	movi r3 121
	sw r3  r2  -1
	lw r3  r2  -1
	sw r3  r2  -2
	lw r3  r2  -2
	sw r3  r2  -3
	movi r3 0
	sw r3  r2  -4
	lw r3  r2  -4
	sw r3  r2  -5
main.while.0.continue:
	movi r3 1
	sw r3  r2  -6
	movi r3 1
	sw r3  r2  -7
	lw r3  r2  -2
	lw r4  r2  -7
	cmp r3  r4 
	bnz 1
	jmp 3
	movi r3 main.end.9
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -6
main.end.9:
	lw r3  r2  -6
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 main.while.0.break
	jalr r0  r3 
	lw r3  r2  -2
	call collatz
	sw r3  r2  -8
	lw r3  r2  -8
	sw r3  r2  -2
	movi r3 1
	sw r3  r2  -9
	lw r3  r2  -2
	lw r4  r2  -3
	cmp r3  r4 
	ba 1
	jmp 3
	movi r3 main.end.4
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -9
main.end.4:
	lw r3  r2  -9
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 main.end.5
	jalr r0  r3 
	lw r3  r2  -2
	sw r3  r2  -3
main.end.5:
	movi r3 1
	sw r3  r2  -10
	lw r3  r2  -5
	lw r4  r2  -10
	add r3  r3  r4 
	sw r3  r2  -5
	movi r3 main.while.0.continue
	jalr r0  r3 
main.while.0.break:
	lw r3  r2  -3
	sw r3  r2  -11
	lw r3  r2  -11
	# Function Epilogue
	sys EXIT
	movi r3 0
	# Function Epilogue
	sys EXIT


# add, div, and mod can probably be more efficient using shifts
# shl and shr should check if second parameter is >16 and return 0 if so
# but im lazy and this works for now
smul:
	sw r5 r1 -1 # push registers
	sw r6 r1 -2 
	# check sign of inputs, store results in r6
	# if inputs are negative, negate them
	lui r5 0x8000
	add r6 r0 r0
	and r0 r3 r5
	bz smul_check_r4
	addi r6 r6 1
	sub r3 r0 r3
smul_check_r4:
	and r0 r4 r5
	bz smul_pos
	addi r6 r6 1
	sub r4 r0 r4
smul_pos:
	addi r5 r0 0
smul_loop: # repeated addition
	cmp r3 r0
	bz smul_end
	addi r3 r3 -1
	add r5 r5 r4
	jmp smul_loop
smul_end:
	addi r6 r6 -1
	bnz smul_skip_negate
	sub r5 r0 r5 # fix sign of result
smul_skip_negate:
	mov r3 r5
	lw r5 r1 -1 # pop registers
	lw r6 r1 -2 
	jalr r0 r7

sdiv:
	sw r5 r1 -1 # push registers
	sw r6 r1 -2 
	# check sign of inputs, store results in r6
	lui r5 0x8000
	add r6 r0 r0
	and r0 r3 r5
	bz sdiv_check_r4
	addi r6 r6 1
	sub r3 r0 r3
sdiv_check_r4:
	and r0 r4 r5
	bz sdiv_pos
	addi r6 r6 1
	sub r4 r0 r4
sdiv_pos:
	add r5 r0 r0
sdiv_loop: # repeated subtraction
	cmp r3 r4
	bn sdiv_end
	addi r5 r5 1
	sub r3 r3 r4
	jmp sdiv_loop
sdiv_end:
	addi r6 r6 -1
	bnz sdiv_skip_negate
	sub r5 r0 r5
sdiv_skip_negate:
	mov r3 r5
	lw r5 r1 -1 # pop registers
	lw r6 r1 -2 
	jalr r0 r7

smod:
	sw r5 r1 -1 # push registers
	sw r6 r1 -2 
	# check sign of inputs, store results in r6
	lui r5 0x8000
	add r6 r0 r0
	and r0 r3 r5
	bz smod_check_r4
	addi r6 r6 1
	sub r3 r0 r3
smod_check_r4:
	and r0 r4 r5
	bz smod_pos
	addi r6 r6 1
	sub r4 r0 r4
smod_pos:
	add r5 r0 r0
smod_loop: # repeated subtraction
	cmp r3 r4
	bn smod_end
	sub r3 r3 r4
	jmp smod_loop
smod_end:
	addi r6 r6 -1
	bnz smod_skip_negate
	sub r3 r4 r3 # ensure result is between 0 and r4
smod_skip_negate:
	lw r5 r1 -1 # pop registers
	lw r6 r1 -2 
	jalr r0 r7

umul:
	sw r5 r1 -1 # push registers
	sw r6 r1 -2 
	addi r5 r0 0
umul_loop: # repeated addition
	cmp r3 r0
	bz umul_end
	addi r3 r3 -1
	add r5 r5 r4
	jmp umul_loop
umul_end:
	mov r3 r5
	lw r5 r1 -1 # pop registers
	lw r6 r1 -2 
	jalr r0 r7

udiv:
	sw r5 r1 -1 # push registers
	sw r6 r1 -2 
	add r5 r0 r0
udiv_loop: # repeated subtraction
	cmp r3 r4
	bb udiv_end
	addi r5 r5 1
	sub r3 r3 r4
	jmp udiv_loop
udiv_end:
	mov r3 r5
	lw r5 r1 -1 # pop registers
	lw r6 r1 -2 
	jalr r0 r7

umod:
	sw r5 r1 -1 # push registers
	sw r6 r1 -2 
	add r5 r0 r0
umod_loop: # repeated subtraction
	cmp r3 r4
	bb umod_end
	sub r3 r3 r4
	jmp umod_loop
umod_end:
	lw r5 r1 -1 # pop registers
	lw r6 r1 -2 
	jalr r0 r7
	
left_shift:
	sw r5 r1 -1 # push registers
	# check sign of r4
	# if negative, do right shift instead
	lui r5 0x8000
	and r0 r5 r4
	bz ls_loop
	sub r4 r0 r4
	jmp rs_loop
ls_loop: # repeated shift
	cmp r4 r0
	bz ls_end
	addi r4 r4 -1
	shl r3 r3
	jmp ls_loop
ls_end:
	lw r5 r1 -1 # pop registers
	jalr r0 r7
	
	
right_shift:
	sw r5 r1 -1 # push registers
	# check sign of r4
	# if negative, do left shift instead
	lui r5 0x8000
	and r0 r5 r4
	bz rs_loop
	sub r4 r0 r4
	jmp ls_loop
rs_loop: # repeated shift
	cmp r4 r0
	bz rs_end
	addi r4 r4 -1
	sshr r3 r3
	jmp rs_loop
rs_end:
	lw r5 r1 -1 # pop registers
	jalr r0 r7