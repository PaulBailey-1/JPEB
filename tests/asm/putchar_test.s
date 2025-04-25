  movi r1, 0x9FFF
  movi r2, 0x9FFF
  movi r3, 0x41
  call putchar
  sys EXIT


# Data Section:
line_index:
	.fill 0
cursor_index:
	.fill 0
ZERO_CHAR:
	.fill 48

# Code Section:
putchar:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -34
	sw r3  r2  -1
	movi r3 64
	sw r3  r2  -2
	lw r3  r2  -2
	movi r4 line_index
	lw r4  r4  0
	call umul
	sw r3  r2  -3
	movi r3 FRAMEBUFFER_START
	lw r3  r3  0
	lw r4  r2  -3
	add r3  r3  r4 
	sw r3  r2  -4
	movi r3 2
	sw r3  r2  -5
	movi r3 cursor_index
	lw r3  r3  0
	lw r4  r2  -5
	call udiv
	sw r3  r2  -6
	lw r3  r2  -4
	lw r4  r2  -6
	add r3  r3  r4 
	sw r3  r2  -7
	lw r3  r2  -7
	sw r3  r2  -8
	lw r3  r2  -8
	sw r3  r2  -9
	movi r3 1
	sw r3  r2  -10
	movi r3 1
	sw r3  r2  -11
	movi r3 10
	sw r3  r2  -12
	lw r3  r2  -1
	lw r4  r2  -12
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 putchar.end.9
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -11
putchar.end.9:
	lw r3  r2  -11
	movi r4 0
	cmp r3  r4 
	bnz 1
	jmp 3
	movi r3 putchar.end.14
	jalr r0  r3 
	movi r3 1
	sw r3  r2  -13
	movi r3 13
	sw r3  r2  -14
	lw r3  r2  -1
	lw r4  r2  -14
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 putchar.end.12
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -13
putchar.end.12:
	lw r3  r2  -13
	movi r4 0
	cmp r3  r4 
	bnz 1
	jmp 3
	movi r3 putchar.end.14
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -10
putchar.end.14:
	lw r3  r2  -10
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 putchar.end.18
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -15
	lw r3  r2  -15
	movi r4 cursor_index
	sw r3  r4  0
	movi r3 line_index
	lw r3  r3  0
	sw r3  r2  -16
	movi r3 line_index
	lw r3  r3  0
	movi r4 1
	add r3  r3  r4 
	movi r4 line_index
	sw r3  r4  0
	movi r3 0
	sw r3  r2  -17
	lw r3  r2  -17
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
putchar.end.18:
	movi r3 1
	sw r3  r2  -18
	movi r3 cursor_index
	lw r3  r3  0
	lw r4  r2  -18
	and r3  r3  r4 
	sw r3  r2  -19
	lw r3  r2  -19
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 putchar.else.25
	jalr r0  r3 
	lw r3  r2  -9
	lw r4  r3  0
	sw r4  r2  -20
	movi r3 8
	sw r3  r2  -21
	lw r3  r2  -1
	lw r4  r2  -21
	call left_shift
	sw r3  r2  -22
	lw r3  r2  -20
	lw r4  r2  -22
	or r3  r3  r4 
	sw r3  r2  -23
	lw r3  r2  -9
	lw r4  r2  -23
	sw r4  r3  0
	movi r3 putchar.end.26
	jalr r0  r3 
putchar.else.25:
	lw r3  r2  -9
	lw r4  r2  -1
	sw r4  r3  0
putchar.end.26:
	movi r3 cursor_index
	lw r3  r3  0
	sw r3  r2  -24
	movi r3 cursor_index
	lw r3  r3  0
	movi r4 1
	add r3  r3  r4 
	movi r4 cursor_index
	sw r3  r4  0
	movi r3 RESOLUTION_REG
	lw r3  r3  0
	sw r3  r2  -25
	lw r3  r2  -25
	sw r3  r2  -9
	lw r3  r2  -9
	lw r4  r3  0
	sw r4  r2  -26
	lw r3  r2  -26
	sw r3  r2  -27
	lw r3  r2  -27
	sw r3  r2  -28
	movi r3 80
	lw r4  r2  -28
	call right_shift
	sw r3  r2  -29
	lw r3  r2  -29
	sw r3  r2  -30
	movi r3 1
	sw r3  r2  -31
	lw r3  r2  -30
	sw r3  r2  -32
	movi r3 cursor_index
	lw r3  r3  0
	lw r4  r2  -32
	cmp r3  r4 
	bae 1
	jmp 3
	movi r3 putchar.end.34
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -31
putchar.end.34:
	lw r3  r2  -31
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 putchar.end.37
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -33
	lw r3  r2  -33
	movi r4 cursor_index
	sw r3  r4  0
	movi r3 line_index
	lw r3  r3  0
	sw r3  r2  -34
	movi r3 line_index
	lw r3  r3  0
	movi r4 1
	add r3  r3  r4 
	movi r4 line_index
	sw r3  r4  0
putchar.end.37:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
print_unsigned:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -11
	sw r3  r2  -1
	movi r3 10
	sw r3  r2  -2
	lw r3  r2  -1
	lw r4  r2  -2
	call umod
	sw r3  r2  -3
	lw r3  r2  -3
	sw r3  r2  -4
	movi r3 10
	sw r3  r2  -5
	lw r3  r2  -1
	lw r4  r2  -5
	call udiv
	sw r3  r2  -6
	lw r3  r2  -6
	sw r3  r2  -1
	movi r3 1
	sw r3  r2  -7
	movi r3 0
	sw r3  r2  -8
	lw r3  r2  -1
	lw r4  r2  -8
	cmp r3  r4 
	bnz 1
	jmp 3
	movi r3 print_unsigned.end.6
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -7
print_unsigned.end.6:
	lw r3  r2  -7
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 print_unsigned.end.8
	jalr r0  r3 
	lw r3  r2  -1
	call print_unsigned
	sw r3  r2  -9
print_unsigned.end.8:
	movi r3 ZERO_CHAR
	lw r3  r3  0
	lw r4  r2  -4
	add r3  r3  r4 
	sw r3  r2  -10
	lw r3  r2  -10
	call putchar
	sw r3  r2  -11
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
reset_cursor:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -2
	movi r3 0
	sw r3  r2  -1
	lw r3  r2  -1
	movi r4 cursor_index
	sw r3  r4  0
	movi r3 0
	sw r3  r2  -2
	lw r3  r2  -2
	movi r4 line_index
	sw r3  r4  0
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
clear:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -2
	call reset_cursor
	sw r3  r2  -1
	call clear_screen
	sw r3  r2  -2
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
print:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -7
	sw r3  r2  -1
	lw r3  r2  -1
	sw r3  r2  -2
print.for.0.start:
	movi r3 1
	sw r3  r2  -3
	lw r3  r2  -2
	lw r4  r3  0
	sw r4  r2  -4
	movi r3 0
	sw r3  r2  -5
	lw r3  r2  -4
	lw r4  r2  -5
	cmp r3  r4 
	bnz 1
	jmp 3
	movi r3 print.end.5
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -3
print.end.5:
	lw r3  r2  -3
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 print.for.0.break
	jalr r0  r3 
	lw r3  r2  -2
	lw r4  r3  0
	sw r4  r2  -6
	lw r3  r2  -6
	call putchar
	sw r3  r2  -7
print.for.0.continue:
	lw r3  r2  -2
	movi r4 1
	add r3  r3  r4 
	sw r3  r2  -2
	movi r3 print.for.0.start
	jalr r0  r3 
print.for.0.break:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 


# Data Section:
UART_TX_REG:
	.fill 61440
SPRITE_7_Y:
	.fill 65519
SPRITE_7_X:
	.fill 65518
SPRITE_6_Y:
	.fill 65517
SPRITE_6_X:
	.fill 65516
SPRITE_5_Y:
	.fill 65515
SPRITE_5_X:
	.fill 65514
SPRITE_4_Y:
	.fill 65513
SPRITE_4_X:
	.fill 65512
SPRITE_3_Y:
	.fill 65511
SPRITE_3_X:
	.fill 65510
SPRITE_2_Y:
	.fill 65509
SPRITE_2_X:
	.fill 65508
SPRITE_1_Y:
	.fill 65507
SPRITE_1_X:
	.fill 65506
SPRITE_0_Y:
	.fill 65505
SPRITE_0_X:
	.fill 65504
SPRITE_DATA_START:
	.fill 40960
SCROLL_Y:
	.fill 65534
SCROLL_X:
	.fill 65533
TILEMAP_START:
	.fill 49152
INPUT_STREAM:
	.fill 65535
RESOLUTION_REG:
	.fill 65532
FRAMEBUFFER_START:
	.fill 57344

# Code Section:

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


# assembly implementation so its faster
clear_screen:
  movi r3, 4096 # 64 x 64
  movi r4, FRAMEBUFFER_START
  lw   r4, r4, 0
clear_screen_loop:
  sw   r0, r4, 0
  addi r4, r4, 1
  addi r3, r3, -1
  bnz  clear_screen_loop
  jalr r0, r7