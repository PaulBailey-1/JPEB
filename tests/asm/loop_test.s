	movi r3 main #0, 1
	jalr r0  r3  # 2

# Data Section:

# Code Section:
main:
	movi r1 40959 # 3, 4
	movi r2 40959 # 5, 6
	addi r1  r1  -3 # 7
	movi r3 0 # 8, 9
	sw r3  r2  -1 # A
	movi r3 0 # B, C
	sw r3  r2  -2 # D
main.for.0.start:
	movi r3 1 # E, F
	sw r3  r2  -3 # 10
	lw r3  r2  -2 # 11
	movi r4 10 # 12, 13
	cmp r3  r4  # 14
	bl 1 # 15
	jmp 3 # 16 
	movi r3 main.end.1 # 17, 18
	jalr r0  r3 # 19
	movi r3 0 # 1A, 1B
	sw r3  r2  -3 # 1D
main.end.1:
	lw r3  r2  -3 # 1E
	movi r4 0 # 1F, 20
	cmp r3  r4 # 21
	bz 1 # 22
	jmp 3 # 23
	movi r3 main.for.0.break # 24, 25
	jalr r0  r3 # 26
	lw r3  r2  -1 # 27
	lw r4  r2  -2 # 28
	add r3  r3  r4 # 29
	sw r3  r2  -1 # 2A
main.for.0.continue:
	lw r3  r2  -2 # 2B
	movi r4 1 # 2C, 2D
	add r3  r3  r4 # 2E
	sw r3  r2  -2 # 2F
	movi r3 main.for.0.start # 30, 31
	jalr r0  r3 # 32
main.for.0.break:
	lw r3  r2  -1 # 33
	# Function Epilogue
	sys EXIT # 34
	movi r3 0 # 35, 36
	# Function Epilogue
	sys EXIT # 37
