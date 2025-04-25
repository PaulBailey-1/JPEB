# note that this follows the following ISA convensions
# r1 = stack pointer
# r7 = return link

INIT:
  
PRESS_SPACE_TO_START:
  movi r3, TPRESS_SPACE_TO_START
  call print
  # increase scale to see text
  movi r4, 0xFFFC
  movi r3, 2
  sw r3, r4, 0
LPRESS_SPACE_TO_START:
  # movi r4, 0xFFFF
  # lw r4, r4, 0
  # movi r3, 0x20
  # cmp r4, r3
  # bne LPRESS_SPACE_TO_START
  call clear_screen
  # restore scale 
  movi r4, 0xFFFC
  sw r0, r4, 0

LAPPLE_INIT:
LSNAKE_INIT:
  # the data is stored at DATA
  # at offset 0 is the snake's body's coordinates
  movi r4, DATA
  # the center coordinate is (x,y) = (40, 30)
  movi r3, 0x281e
  sw r3, r4, 0
  addi r3, r3, 1    # lower order bytes is y
  sw r3, r4, 1
  # the length of the snake
  movi r4, SNAKE_LENGTH
  movi r3, 2
  sw r3, r4, 0
  # the color of the snake
  movi r4, COLOR_STATE
  movi r3, 1
  sw r3, r4, 0
  #graphics
  # push previous return address
  push r7
  call FCOLOR_SNAKE
  pop r7
LMOTION_INIT:
  movi r4, DIRECTION
  movi r3, 0x00FF
  sw r3, r4, 0
MAIN:
  movi r4, LOOP_COUNT
  lw r3, r4, 0
LSTALL:
  addi r3, r3, -1
  bnz LSTALL
  lw r3, r4, 0
LMOVE:
  movi r4, 0xFFFF
  lw r3, r4, 0 # get a key press
  movi r4, DIRECTION
  lw r6, r4, 0 # copy original direction into r6

  movi r5, 119 # 'w'
  cmp r3, r5 # 'w'
  bne NOTW
  movi r3, 0x00FF
  jmp LKEY_PRESSED
NOTW:
  movi r5, 97 # 'a'
  cmp r3, r5 # 'a'
  bne NOTA
  movi r3, 0xFF00
  jmp LKEY_PRESSED
NOTA:
  movi r5, 115 # 's'
  cmp r3, r5 # 's'
  bne NOTS
  movi r3, 0x0001
  jmp LKEY_PRESSED
NOTS:
  movi r5, 100 # 'd'
  cmp r3, r5 # 'd'
  bne NOTD
  movi r3, 0x0100
  jmp LKEY_PRESSED
NOTD:
  jmp LCLEAR_SNAKE # not a key press
LKEY_PRESSED:
  add r6, r6, r3
  movi r5, 0xFEFF
  and r6, r6, r5 # mask to see if 0
  cmp r6, r0
  bz LCLEAR_SNAKE # going in reversed direction
  sw r3, r4, 0
LCLEAR_SNAKE:
  # clear snake for redrawing
  movi r4, COLOR_STATE
  sw r0, r4, 0
  push r7
  call FCOLOR_SNAKE
  pop r7
LADVANCE_SNAKE:
  # load next position
  movi r4, DIRECTION
  lw r3, r4, 0  # the direction the snake was going
  # perform move
  movi r4, DATA
  lw r5, r4, 0 # the original head of the snake

  # if next position is border, we die (i.e. if carry in y or x)
  # left and top overflow are equivalent to right and bottom overflow, resp
  # right overflow
  add r2, r5, r3
  movi r6, 0x5000
  cmp r2, r6
  bae LFAIL_ADV # too far right
  # down overflow
  movi r6, 0x00FF # we use this to mask out the y coordinate
  and r2, r2, r6
  movi r6, 0x3C
  cmp r2, r6
  bae LFAIL_ADV # too far down
  jmp LEND_CHECKWALL
LFAIL_ADV:
  movi r4, FEND
  jalr r0, r4
LEND_CHECKWALL:
  # correct for drift due to carry between y and x
  movi r6, 0x00FF
  and r6, r3, r6
  addi r2, r6, 1
  movi r6, 0x0100
  and r2, r2, r6 # get carry bit
  add r3, r3, r5 # r3 will store next position 
  sub r3, r3, r2

  # if next position is part of snake (except tail), we die
  # we are in a sweet spot here where none of the registers except r3 matter
  push r7
  call FIN_SNAKE
  pop r7
  cmp r4, r0
  bz LFAIL_ADV

  movi r4, SNAKE_LENGTH
  lw r2, r4, 0
  # if next position is apple, we increase snake length and generate another apple
  movi r5, APPLE
  lw r5, r5, 0
  cmp r3, r5
  bne LEND_CHECKAPPLE
  # increase snake length
  addi r2, r2, 1
  sw r2, r4, 0

LEND_CHECKAPPLE:
  movi r4, DATA
LMOVE_FORWARD:
  lw r5, r4, 0
  sw r3, r4, 0
  add r3, r0, r5
  addi r4, r4, 1
  addi r2, r2, -1
  bnz LMOVE_FORWARD

  movi r4, COLOR_STATE
  movi r3, 1
  sw r3, r4, 0
  push r7
  call FCOLOR_SNAKE
  pop r7

  movi r4, MAIN
  jalr r0, r4

# to set the apple to a certain color, call this function with COLOR_STATE set to the desired color
# to set the apple at a certain location, pass the location in {x:hi,y:lo} via r4
# will preserve r1, r2, r7
FCOLOR_APPLE:
  # get the tile address into r4
  add r6, r0, r4
  movi r3, 0xFF
  and r3, r3, r6
  shl r3, r3    # shl 6 times (for 'y')
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shr r6, r6    # shr 9 times (for 'x')
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  movi r5, 1
  and r5, r5, r6 # grab the even/odd bit before losing it
  shr r6, r6
  # r6 will be x
  # if r5 (the sign) is even, the output will be OR'ed into the lower bits otherwise will OR into the upper bits
  # calculate address
  add r4, r3, r6
  movi r3, 0xE000
  add r4, r3, r4
  # check even/odd
  # get original value to OR with and store the OR'd result in r6
  lw r3, r4, 0 # r3 is the original
  cmp r5, r0
  bnz LENDEVEN

  # even -> lower order bits
  movi r6, 0xFF00
  and r6, r3, r6
  movi r3, COLOR_STATE
  lw r3, r3, 0
  add r6, r6, r3
  jmp LENDODD
LENDEVEN:
  # odd -> upper order bits
  movi r6, 0x00FF
  and r6, r3, r6
  movi r3, COLOR_STATE
  lw r3, r3, 0
  shl r3, r3  # shl 8 bits
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  add r6, r6, r3
LENDODD:
  # draw to screen
  sw r6, r4, 0
  jalr r0, r7 # return

# to set the snake to a certian color, call this function with COLOR_STATE set to the desired color
FCOLOR_SNAKE:
  # the loop
  movi r2, SNAKE_LENGTH
  lw r2, r2, 0
LFILL:
  # we assume snake always has some length to body
  addi r2, r2, -1

  movi r4, DATA   # load from snake body
  add r4, r4, r2
  lw r4, r4, 0
  
  # a snake is really just many apples
  push r7
  call FCOLOR_APPLE
  pop r7

  cmp r2, r0 # check not zero
  bnz LFILL
  jalr r0, r7 # return


# expects the position to check for to be in r3
# keeps the position in r3 and sets r4 to 0/non-0 for fail/success
# doesn't check tail nor head
FIN_SNAKE:
  movi r2, SNAKE_LENGTH
  lw r2, r2, 0
  addi r2, r2, -2
LIN_SNAKE:
  movi r4, DATA
  add r4, r4, r2
  lw r4, r4, 0
  sub r4, r3, r4
  bz LIN_SNAKE_DONE
  addi r2, r2, -1
  bg LIN_SNAKE
LIN_SNAKE_DONE:
  jalr r0, r7

# expects the end bound (exclusive) to be in r3
# the end bound should be no more than 0xFF
FRANDOM:
  push r3
  # Linear Congruential Generator (LCG)
  movi r4, RANDOM_SEED
  lw r3, r4, 0
  movi r5, 0x4E6D  # Multiplier
  xor r3, r3, r5
  movi r5, 0x6073       # Increment
  add r3, r3, r5
  sw r3, r4, 0
  # reduce the size of number
  movi r4, 0xFF
  and r3, r3, r4
  # Modulo operation to get number in range
  pop r4
  push r7
  call umod
  pop r7
  jalr r0, r7
RANDOM_SEED:
  .fill 0x1023
LOOP_COUNT: # the number of cycles to stall in the main loop
  .fill 65000
DIRECTION:
  .fill 0x0001
COLOR_STATE:
  .fill 2
DATA:
  .space 4800
APPLE:
  .fill 0x1024
SNAKE_LENGTH:
  .fill 2
HIGH_SCORE:
  .fill 0
TPRESS_SPACE_TO_START:
  .fill 0x50
  .fill 0x52
  .fill 0x45
  .fill 0x53
  .fill 0x53
  .fill 0x20
  .fill 0x53
  .fill 0x50
  .fill 0x41
  .fill 0x43
  .fill 0x45
  .fill 0x20
  .fill 0x54
  .fill 0x4F
  .fill 0x20
  .fill 0x53
  .fill 0x54
  .fill 0x41
  .fill 0x52
  .fill 0x54
  .fill 0x00
TSCORE:
  .fill 0x53
  .fill 0x43
  .fill 0x4F
  .fill 0x52
  .fill 0x45
  .fill 0x20
  .fill 0x00
FEND:
  movi r3, TSCORE
  call print
  movi r4, SNAKE_LENGTH
  lw r3, r4, 0
  addi r3, r3, -2
  push r3
  call print_unsigned
  # determine if new high score
  movi r4, HIGH_SCORE
  lw r4, r4, 0
  pop r3
  cmp r3, r4
  ble LNOT_HIGH_SCORE
  call FHIGH_SCORE
LNOT_HIGH_SCORE:
  movi r3, 0x0A
  call putchar
  # increase scale to see score
  movi r4, 0xFFFC
  movi r3, 2
  sw r3, r4, 0
  # movi r4, PRESS_SPACE_TO_START
  # jalr r0, r4
  sys EXIT

FHIGH_SCORE:
  movi r4, HIGH_SCORE
  sw r3, r4, 0
  # summoning high score sign
  movi r4, 0xFFE0
  movi r3, 304
  sw r3, r4, 0
  movi r3, 0
LHIGH_SCORE_DROP:
  addi r3, r3, 1
  sw r3, r4, 1
  movi r2, LOOP_COUNT
  lw r2, r2, 0
LHIGH_SCORE_STALL:
  addi r2, r2, -1
  bnz LHIGH_SCORE_STALL
  movi r2, 480
  cmp r2, r3
  bnz LHIGH_SCORE_DROP
  jalr r0, r7


write_text_tilemap: # first param is text color, ssecond is bg color
		push r2
    mov  r6 r3
    movi r2 0xC800
    movi r3 0xE000
write_text_tilemap_loop:
    sw   r4 r2 0
    addi r2 r2 1
    cmp  r2 r3
    bnz  write_text_tilemap_loop
  	movi r2 text_tilemap
  	mov  r4 r6
  	movi r5 text_tilemap_end
write_text_tilemap_loop_2:
  	lw   r3 r2 0
  	sw   r4 r3 0
  	addi r2 r2 1
  	cmp  r2 r5
  	bnz  write_text_tilemap_loop_2
		pop r2
  	jalr r0 r7

write_text_tilemap_all: # first param is text color, ssecond is bg color
		push r2
    mov  r6 r3
    movi r2 0xC000
    movi r3 0xE000
write_text_tilemap_all_loop:
    sw   r4 r2 0
    addi r2 r2 1
    cmp  r2 r3
    bnz  write_text_tilemap_all_loop
  	movi r2 text_tilemap
  	mov  r4 r6
  	movi r5 text_tilemap_end
write_text_tilemap_all_loop_2:
  	lw   r3 r2 0
  	sw   r4 r3 0
  	addi r2 r2 1
  	cmp  r2 r5
  	bnz  write_text_tilemap_all_loop_2
		pop r2
  	jalr r0 r7

text_tilemap:
	# space

	# !
	.fill 0xC84B
	.fill 0xC853
	.fill 0xC85B
	.fill 0xC863
	.fill 0xC873

	# "
	.fill 0xC88B
	.fill 0xC88D
	.fill 0xC893
	.fill 0xC895

	# #
	.fill 0xC8CA
	.fill 0xC8CD
	.fill 0xC8D1
	.fill 0xC8D2
	.fill 0xC8D3
	.fill 0xC8D4
	.fill 0xC8D5
	.fill 0xC8D6
	.fill 0xC8DA
	.fill 0xC8DD
	.fill 0xC8E2
	.fill 0xC8E5
	.fill 0xC8E9
	.fill 0xC8EA
	.fill 0xC8EB
	.fill 0xC8EC
	.fill 0xC8ED
	.fill 0xC8EE
	.fill 0xC8F2
	.fill 0xC8F5

	# $
	.fill 0xC90B
	.fill 0xC912
	.fill 0xC913
	.fill 0xC914
	.fill 0xC915
	.fill 0xC919
	.fill 0xC91B
	.fill 0xC922
	.fill 0xC923
	.fill 0xC924
	.fill 0xC92B
	.fill 0xC92D
	.fill 0xC931
	.fill 0xC932
	.fill 0xC933
	.fill 0xC934

	# %
	.fill 0xC949
	.fill 0xC94A
	.fill 0xC94E
	.fill 0xC951
	.fill 0xC952
	.fill 0xC955
	.fill 0xC95C
	.fill 0xC963
	.fill 0xC96A
	.fill 0xC96D
	.fill 0xC96E
	.fill 0xC971
	.fill 0xC975
	.fill 0xC976

	# &
	.fill 0xC98B
	.fill 0xC98C
	.fill 0xC992
	.fill 0xC995
	.fill 0xC99B
	.fill 0xC99C
	.fill 0xC9A3
	.fill 0xC9A4
	.fill 0xC9A6
	.fill 0xC9AA
	.fill 0xC9AD
	.fill 0xC9B3
	.fill 0xC9B4
	.fill 0xC9B6

	# '
	.fill 0xC9CC
	.fill 0xC9D4

	# (
	.fill 0xCA0C
	.fill 0xCA13
	.fill 0xCA1B
	.fill 0xCA23
	.fill 0xCA2B
	.fill 0xCA34

	# )
	.fill 0xCA4B
	.fill 0xCA54
	.fill 0xCA5C
	.fill 0xCA64
	.fill 0xCA6C
	.fill 0xCA73

	# *
	.fill 0xCA8B
	.fill 0xCA8D
	.fill 0xCA94
	.fill 0xCA9B
	.fill 0xCA9D

	# +
	.fill 0xCAD4
	.fill 0xCADC
	.fill 0xCAE2
	.fill 0xCAE3
	.fill 0xCAE4
	.fill 0xCAE5
	.fill 0xCAE6
	.fill 0xCAEC
	.fill 0xCAF4

	# ,
	.fill 0xCB2A
	.fill 0xCB31
	.fill 0xCB32

	# -
	.fill 0xCB62
	.fill 0xCB63
	.fill 0xCB64
	.fill 0xCB65

	# . 
	.fill 0xCBAB
	.fill 0xCBAC
	.fill 0xCBB3
	.fill 0xCBB4

	# /
	.fill 0xCBCD
	.fill 0xCBD5
	.fill 0xCBDC
	.fill 0xCBE3
	.fill 0xCBEA
	.fill 0xCBF2

	# 0
	.fill 0xCC0A
	.fill 0xCC0B
	.fill 0xCC0C
	.fill 0xCC0D
	.fill 0xCC12
	.fill 0xCC15
	.fill 0xCC1A
	.fill 0xCC1D
	.fill 0xCC22
	.fill 0xCC25
	.fill 0xCC2A
	.fill 0xCC2D
	.fill 0xCC32
	.fill 0xCC33
	.fill 0xCC34
	.fill 0xCC35

	# 1
	.fill 0xCC4B
	.fill 0xCC4C
	.fill 0xCC54
	.fill 0xCC5C
	.fill 0xCC64
	.fill 0xCC6C
	.fill 0xCC73
	.fill 0xCC74
	.fill 0xCC75

	# 2
	.fill 0xCC8B
	.fill 0xCC8C
	.fill 0xCC92
	.fill 0xCC95
	.fill 0xCC9D
	.fill 0xCCA4
	.fill 0xCCAB
	.fill 0xCCB2
	.fill 0xCCB3
	.fill 0xCCB4
	.fill 0xCCB5

	# 3
	.fill 0xCCCA
	.fill 0xCCCB
	.fill 0xCCCC
	.fill 0xCCD5
	.fill 0xCCDA
	.fill 0xCCDB
	.fill 0xCCDC
	.fill 0xCCE5
	.fill 0xCCED
	.fill 0xCCF2
	.fill 0xCCF3
	.fill 0xCCF4

	# 4
	.fill 0xCD0A
	.fill 0xCD0D
	.fill 0xCD12
	.fill 0xCD15
	.fill 0xCD1A
	.fill 0xCD1B
	.fill 0xCD1C
	.fill 0xCD1D
	.fill 0xCD25
	.fill 0xCD2D
	.fill 0xCD35

	# 5
	.fill 0xCD4A
	.fill 0xCD4B
	.fill 0xCD4C
	.fill 0xCD4D
	.fill 0xCD52
	.fill 0xCD5A
	.fill 0xCD5B
	.fill 0xCD5C
	.fill 0xCD65
	.fill 0xCD6A
	.fill 0xCD6D
	.fill 0xCD73
	.fill 0xCD74

	# 6
	.fill 0xCD8A
	.fill 0xCD8B
	.fill 0xCD8C
	.fill 0xCD8D
	.fill 0xCD92
	.fill 0xCD9A
	.fill 0xCD9B
	.fill 0xCD9C
	.fill 0xCD9D
	.fill 0xCDA2
	.fill 0xCDA5
	.fill 0xCDAA
	.fill 0xCDAD
	.fill 0xCDB2
	.fill 0xCDB3
	.fill 0xCDB4
	.fill 0xCDB5

	# 7
	.fill 0xCDCA
	.fill 0xCDCB
	.fill 0xCDCC
	.fill 0xCDCD
	.fill 0xCDD5
	.fill 0xCDDD
	.fill 0xCDE5
	.fill 0xCDED
	.fill 0xCDF5

	# 8
	.fill 0xCE0B
	.fill 0xCE0C
	.fill 0xCE12
	.fill 0xCE15
	.fill 0xCE1B
	.fill 0xCE1C
	.fill 0xCE22
	.fill 0xCE25
	.fill 0xCE2A
	.fill 0xCE2D
	.fill 0xCE33
	.fill 0xCE34

	# 9
	.fill 0xCE4A
	.fill 0xCE4B
	.fill 0xCE4C
	.fill 0xCE4D
	.fill 0xCE52
	.fill 0xCE55
	.fill 0xCE5A
	.fill 0xCE5B
	.fill 0xCE5C
	.fill 0xCE5D
	.fill 0xCE65
	.fill 0xCE6D
	.fill 0xCE75

	# :
	.fill 0xCE94
	.fill 0xCEAC

	# ;
	.fill 0xCED4
	.fill 0xCEEC
	.fill 0xCEF3
	.fill 0xCEF4

	# <
	.fill 0xCF15
	.fill 0xCF16
	.fill 0xCF1B
	.fill 0xCF1C
	.fill 0xCF21
	.fill 0xCF22
	.fill 0xCF2B
	.fill 0xCF2C
	.fill 0xCF35
	.fill 0xCF36

	# = 
	.fill 0xCF5A
	.fill 0xCF5B
	.fill 0xCF5C
	.fill 0xCF5D
	.fill 0xCF6A
	.fill 0xCF6B
	.fill 0xCF6C
	.fill 0xCF6D

	# >
	.fill 0xCF91
	.fill 0xCF92
	.fill 0xCF9B
	.fill 0xCF9C
	.fill 0xCFA5
	.fill 0xCFA6
	.fill 0xCFAB
	.fill 0xCFAC
	.fill 0xCFB1
	.fill 0xCFB2

	# ?
	.fill 0xCFCC
	.fill 0xCFD3
	.fill 0xCFD5
	.fill 0xCFDD
	.fill 0xCFE4
	.fill 0xCFF4

	# @
	.fill 0xD011
	.fill 0xD012
	.fill 0xD013
	.fill 0xD014
	.fill 0xD015
	.fill 0xD019
	.fill 0xD01D
	.fill 0xD021
	.fill 0xD023
	.fill 0xD024
	.fill 0xD025
	.fill 0xD029
	.fill 0xD02B
	.fill 0xD02D
	.fill 0xD031
	.fill 0xD033
	.fill 0xD034
	.fill 0xD035

	# A
	.fill 0xD04B
	.fill 0xD04C
	.fill 0xD052
	.fill 0xD055
	.fill 0xD05A
	.fill 0xD05D
	.fill 0xD062
	.fill 0xD063
	.fill 0xD064
	.fill 0xD065
	.fill 0xD06A
	.fill 0xD06D
	.fill 0xD072
	.fill 0xD075

	# B
	.fill 0xD08A
	.fill 0xD08B
	.fill 0xD08C
	.fill 0xD092
	.fill 0xD095
	.fill 0xD09A
	.fill 0xD09B
	.fill 0xD09C
	.fill 0xD0A2
	.fill 0xD0A5
	.fill 0xD0AA
	.fill 0xD0AD
	.fill 0xD0B2
	.fill 0xD0B3
	.fill 0xD0B4

	# C
	.fill 0xD0CB
	.fill 0xD0CC
	.fill 0xD0D2
	.fill 0xD0D5
	.fill 0xD0DA
	.fill 0xD0E2
	.fill 0xD0EA
	.fill 0xD0ED
	.fill 0xD0F3
	.fill 0xD0F4

	# D
	.fill 0xD109
	.fill 0xD10A
	.fill 0xD10B
	.fill 0xD111
	.fill 0xD114
	.fill 0xD119
	.fill 0xD11C
	.fill 0xD121
	.fill 0xD124
	.fill 0xD129
	.fill 0xD12C
	.fill 0xD131
	.fill 0xD132
	.fill 0xD133

	# E
	.fill 0xD149
	.fill 0xD14A
	.fill 0xD14B
	.fill 0xD151
	.fill 0xD159
	.fill 0xD15A
	.fill 0xD161
	.fill 0xD169
	.fill 0xD171
	.fill 0xD172
	.fill 0xD173

	# F
	.fill 0xD189
	.fill 0xD18A
	.fill 0xD18B
	.fill 0xD18C
	.fill 0xD191
	.fill 0xD199
	.fill 0xD19A
	.fill 0xD19B
	.fill 0xD1A1
	.fill 0xD1A9
	.fill 0xD1B1

	# G
	.fill 0xD1CA
	.fill 0xD1CB
	.fill 0xD1CC
	.fill 0xD1D1
	.fill 0xD1D5
	.fill 0xD1D9
	.fill 0xD1E1
	.fill 0xD1E3
	.fill 0xD1E4
	.fill 0xD1E9
	.fill 0xD1ED
	.fill 0xD1F2
	.fill 0xD1F3
	.fill 0xD1F4

  	# H
  	.fill 0xD209
  	.fill 0xD20E
	.fill 0xD211
	.fill 0xD216
	.fill 0xD219
	.fill 0xD21A
	.fill 0xD21B
	.fill 0xD21C
	.fill 0xD21D
	.fill 0xD21E
	.fill 0xD221
	.fill 0xD226
	.fill 0xD229
	.fill 0xD22E
	.fill 0xD231
	.fill 0xD236

	# I
	.fill 0xD24A
	.fill 0xD24B
	.fill 0xD24C
	.fill 0xD253
	.fill 0xD25B
	.fill 0xD263
	.fill 0xD26B
	.fill 0xD272
	.fill 0xD273
	.fill 0xD274

	# J
	.fill 0xD28B
	.fill 0xD28C
	.fill 0xD294
	.fill 0xD29C
	.fill 0xD2A4
	.fill 0xD2AA
	.fill 0xD2AC
	.fill 0xD2B3

	# K
	.fill 0xD2CA
	.fill 0xD2CD
	.fill 0xD2D2
	.fill 0xD2D4
	.fill 0xD2DA
	.fill 0xD2DB
	.fill 0xD2E2
	.fill 0xD2E4
	.fill 0xD2EA
	.fill 0xD2ED
	.fill 0xD2F2
	.fill 0xD2F5

	# L
	.fill 0xD309
	.fill 0xD311
	.fill 0xD319
	.fill 0xD321
	.fill 0xD329
	.fill 0xD331
	.fill 0xD332
	.fill 0xD333

	# M
	.fill 0xD349
	.fill 0xD34D
	.fill 0xD351
	.fill 0xD352
	.fill 0xD354
	.fill 0xD355
	.fill 0xD359
	.fill 0xD35B
	.fill 0xD35D
	.fill 0xD361
	.fill 0xD365
	.fill 0xD369
	.fill 0xD36D
	.fill 0xD371
	.fill 0xD375

	# N
	.fill 0xD389
	.fill 0xD38D
	.fill 0xD391
	.fill 0xD392
	.fill 0xD395
	.fill 0xD399
	.fill 0xD39B
	.fill 0xD39D
	.fill 0xD3A1
	.fill 0xD3A3
	.fill 0xD3A5
	.fill 0xD3A9
	.fill 0xD3AC
	.fill 0xD3AD
	.fill 0xD3B1
	.fill 0xD3B5
	
	# O
	.fill 0xD3CA
	.fill 0xD3CB
	.fill 0xD3CC
	.fill 0xD3D1
	.fill 0xD3D5
	.fill 0xD3D9
	.fill 0xD3DD
	.fill 0xD3E1
	.fill 0xD3E5
	.fill 0xD3E9
	.fill 0xD3ED
	.fill 0xD3F2
	.fill 0xD3F3
	.fill 0xD3F4

	# P
	.fill 0xD40A
	.fill 0xD40B
	.fill 0xD40C
	.fill 0xD412
	.fill 0xD415
	.fill 0xD41A
	.fill 0xD41D
	.fill 0xD422
	.fill 0xD423
	.fill 0xD424
	.fill 0xD42A
	.fill 0xD432

	# Q
	.fill 0xD44A
	.fill 0xD44B
	.fill 0xD44C
	.fill 0xD451
	.fill 0xD455
	.fill 0xD459
	.fill 0xD45D
	.fill 0xD461
	.fill 0xD465
	.fill 0xD46A
	.fill 0xD46B
	.fill 0xD46C
	.fill 0xD474
	.fill 0xD475

	# R
	.fill 0xD489
	.fill 0xD48A
	.fill 0xD48B
	.fill 0xD491
	.fill 0xD494
	.fill 0xD499
	.fill 0xD49C
	.fill 0xD4A1
	.fill 0xD4A2
	.fill 0xD4A3
	.fill 0xD4A9
	.fill 0xD4AC
	.fill 0xD4B1
	.fill 0xD4B4

	# S
	.fill 0xD4CB
	.fill 0xD4CC
	.fill 0xD4CD
	.fill 0xD4D2
	.fill 0xD4DB
	.fill 0xD4DC
	.fill 0xD4E5
	.fill 0xD4EA
	.fill 0xD4ED
	.fill 0xD4F3
	.fill 0xD4F4

	# T
	.fill 0xD509
	.fill 0xD50A
	.fill 0xD50B
	.fill 0xD50C
	.fill 0xD50D
	.fill 0xD513
	.fill 0xD51B
	.fill 0xD523
	.fill 0xD52B
	.fill 0xD533

	# U
	.fill 0xD54A
	.fill 0xD54D
	.fill 0xD552
	.fill 0xD555
	.fill 0xD55A
	.fill 0xD55D
	.fill 0xD562
	.fill 0xD565
	.fill 0xD56A
	.fill 0xD56D
	.fill 0xD573
	.fill 0xD574

	# V
	.fill 0xD589
	.fill 0xD58D
	.fill 0xD591
	.fill 0xD595
	.fill 0xD599
	.fill 0xD59D
	.fill 0xD5A2
	.fill 0xD5A4
	.fill 0xD5AA
	.fill 0xD5AC
	.fill 0xD5B3

	# W
	.fill 0xD5C9
	.fill 0xD5CD
	.fill 0xD5D1
	.fill 0xD5D5
	.fill 0xD5D9
	.fill 0xD5DB
	.fill 0xD5DD
	.fill 0xD5E1
	.fill 0xD5E3
	.fill 0xD5E5
	.fill 0xD5E9
	.fill 0xD5EB
	.fill 0xD5ED
	.fill 0xD5F2
	.fill 0xD5F4

	# X
	.fill 0xD609
	.fill 0xD60D
	.fill 0xD612
	.fill 0xD614
	.fill 0xD61B
	.fill 0xD623
	.fill 0xD62A
	.fill 0xD62C
	.fill 0xD631
	.fill 0xD635

	# Y
	.fill 0xD649
	.fill 0xD64D
	.fill 0xD652
	.fill 0xD654
	.fill 0xD65B
	.fill 0xD663
	.fill 0xD66B
	.fill 0xD673

	# Z
	.fill 0xD689
	.fill 0xD68A
	.fill 0xD68B
	.fill 0xD68C
	.fill 0xD68D
	.fill 0xD694
	.fill 0xD69B
	.fill 0xD6A3
	.fill 0xD6AA
	.fill 0xD6B1
	.fill 0xD6B2
	.fill 0xD6B3
	.fill 0xD6B4
	.fill 0xD6B5

	# [
	.fill 0xD6CB
	.fill 0xD6CC
	.fill 0xD6D3
	.fill 0xD6DB
	.fill 0xD6E3
	.fill 0xD6EB
	.fill 0xD6F3
	.fill 0xD6F4
	
	# \
	.fill 0xD709
	.fill 0xD711
	.fill 0xD71A
	.fill 0xD723
	.fill 0xD72C
	.fill 0xD734

	# ]
	.fill 0xD74B
	.fill 0xD74C
	.fill 0xD754
	.fill 0xD75C
	.fill 0xD764
	.fill 0xD76C
	.fill 0xD773
	.fill 0xD774

	# ^
	.fill 0xD78B
	.fill 0xD792
	.fill 0xD794

	# _
	.fill 0xD7F1
	.fill 0xD7F2
	.fill 0xD7F3
	.fill 0xD7F4
	.fill 0xD7F5
	.fill 0xD7F6

	# `
	.fill 0xD809
	.fill 0xD812
	.fill 0xD81B

	# a
	.fill 0xD852
	.fill 0xD853
	.fill 0xD854
	.fill 0xD855
	.fill 0xD85D
	.fill 0xD862
	.fill 0xD863
	.fill 0xD864
	.fill 0xD865
	.fill 0xD86A
	.fill 0xD86D
	.fill 0xD872
	.fill 0xD873
	.fill 0xD874
	.fill 0xD875

	# b
	.fill 0xD88A
	.fill 0xD892
	.fill 0xD89A
	.fill 0xD8A2
	.fill 0xD8A3
	.fill 0xD8A4
	.fill 0xD8A5
	.fill 0xD8AA
	.fill 0xD8AD
	.fill 0xD8B2
	.fill 0xD8B3
	.fill 0xD8B4
	.fill 0xD8B5

	# c
	.fill 0xD8DA
	.fill 0xD8DB
	.fill 0xD8DC
	.fill 0xD8DD
	.fill 0xD8E2
	.fill 0xD8EA
	.fill 0xD8F2
	.fill 0xD8F3
	.fill 0xD8F4
	.fill 0xD8F5

	# d
	.fill 0xD90D
	.fill 0xD915
	.fill 0xD91D
	.fill 0xD922
	.fill 0xD923
	.fill 0xD924
	.fill 0xD925
	.fill 0xD92A
	.fill 0xD92D
	.fill 0xD932
	.fill 0xD933
	.fill 0xD934
	.fill 0xD935

	# e
	.fill 0xD952
	.fill 0xD953
	.fill 0xD954
	.fill 0xD955
	.fill 0xD95A
	.fill 0xD95D
	.fill 0xD962
	.fill 0xD963
	.fill 0xD964
	.fill 0xD965
	.fill 0xD96A
	.fill 0xD972
	.fill 0xD973
	.fill 0xD974
	.fill 0xD975

	# f
	.fill 0xD98C
	.fill 0xD993
	.fill 0xD995
	.fill 0xD99B
	.fill 0xD9A2
	.fill 0xD9A3
	.fill 0xD9A4
	.fill 0xD9AB
	.fill 0xD9B3

	# g
	.fill 0xD9D2
	.fill 0xD9D3
	.fill 0xD9D4
	.fill 0xD9DA
	.fill 0xD9DC
	.fill 0xD9E2
	.fill 0xD9E3
	.fill 0xD9E4
	.fill 0xD9EC
	.fill 0xD9F2
	.fill 0xD9F3
	.fill 0xD9F4

	# h
	.fill 0xDA0A
	.fill 0xDA12
	.fill 0xDA1A
	.fill 0xDA22
	.fill 0xDA23
	.fill 0xDA24
	.fill 0xDA2A
	.fill 0xDA2C
	.fill 0xDA32
	.fill 0xDA34

	# i
	.fill 0xDA4B
	.fill 0xDA5B
	.fill 0xDA63
	.fill 0xDA6B
	.fill 0xDA73

	# j
	.fill 0xDA8B
	.fill 0xDA9B
	.fill 0xDAA3
	.fill 0xDAA9
	.fill 0xDAAB
	.fill 0xDAB2

	# k
	.fill 0xDACA
	.fill 0xDAD2
	.fill 0xDADA
	.fill 0xDADC
	.fill 0xDAE2
	.fill 0xDAE3
	.fill 0xDAEA
	.fill 0xDAEC
	.fill 0xDAF2
	.fill 0xDAF4

	# l
	.fill 0xDB0B
	.fill 0xDB13
	.fill 0xDB1B
	.fill 0xDB23
	.fill 0xDB2B
	.fill 0xDB33

	# m
	.fill 0xDB5A
	.fill 0xDB5C
	.fill 0xDB61
	.fill 0xDB63
	.fill 0xDB65
	.fill 0xDB69
	.fill 0xDB6B
	.fill 0xDB6D
	.fill 0xDB71
	.fill 0xDB73
	.fill 0xDB75

	# n
	.fill 0xDB9A
	.fill 0xDB9C
	.fill 0xDBA2
	.fill 0xDBA3
	.fill 0xDBA5
	.fill 0xDBAA
	.fill 0xDBAD
	.fill 0xDBB2
	.fill 0xDBB5

	# o
	.fill 0xDBDB
	.fill 0xDBDC
	.fill 0xDBE2
	.fill 0xDBE5
	.fill 0xDBEA
	.fill 0xDBED
	.fill 0xDBF3
	.fill 0xDBF4

	# p
	.fill 0xDC12
	.fill 0xDC13
	.fill 0xDC1A
	.fill 0xDC1C
	.fill 0xDC22
	.fill 0xDC23
	.fill 0xDC2A
	.fill 0xDC32

	# q
	.fill 0xDC53
	.fill 0xDC54
	.fill 0xDC5A
	.fill 0xDC5C
	.fill 0xDC63
	.fill 0xDC64
	.fill 0xDC6C
	.fill 0xDC74
	.fill 0xDC75

	# r
	.fill 0xDC9A
	.fill 0xDC9C
	.fill 0xDCA2
	.fill 0xDCA3
	.fill 0xDCA5
	.fill 0xDCAA
	.fill 0xDCB2

	# s
	.fill 0xDCD3
	.fill 0xDCD4
	.fill 0xDCD5
	.fill 0xDCDA
	.fill 0xDCE3
	.fill 0xDCE4
	.fill 0xDCED
	.fill 0xDCF2
	.fill 0xDCF3
	.fill 0xDCF4

	# t
	.fill 0xDD0B
	.fill 0xDD13
	.fill 0xDD1A
	.fill 0xDD1B
	.fill 0xDD1C
	.fill 0xDD23
	.fill 0xDD2B
	.fill 0xDD33

	# u
	.fill 0xDD5A
	.fill 0xDD5D
	.fill 0xDD62
	.fill 0xDD65
	.fill 0xDD6A
	.fill 0xDD6D
	.fill 0xDD73
	.fill 0xDD74

	# v
	.fill 0xDD99
	.fill 0xDD9D
	.fill 0xDDA2
	.fill 0xDDA4
	.fill 0xDDAA
	.fill 0xDDAC
	.fill 0xDDB3

	# w
	.fill 0xDDD9
	.fill 0xDDDD
	.fill 0xDDE1
	.fill 0xDDE5
	.fill 0xDDE9
	.fill 0xDDEB
	.fill 0xDDED
	.fill 0xDDF2
	.fill 0xDDF4

	# x
	.fill 0xDE1A
	.fill 0xDE1D
	.fill 0xDE23
	.fill 0xDE24
	.fill 0xDE2B
	.fill 0xDE2C
	.fill 0xDE32
	.fill 0xDE35

	# y
	.fill 0xDE52
	.fill 0xDE54
	.fill 0xDE5A
	.fill 0xDE5C
	.fill 0xDE62
	.fill 0xDE63
	.fill 0xDE64
	.fill 0xDE6C
	.fill 0xDE72
	.fill 0xDE73
	.fill 0xDE74

	# z
	.fill 0xDE9A
	.fill 0xDE9B
	.fill 0xDE9C
	.fill 0xDE9D
	.fill 0xDEA4
	.fill 0xDEAB
	.fill 0xDEB2
	.fill 0xDEB3
	.fill 0xDEB4
	.fill 0xDEB5

	# {
	.fill 0xDECB
	.fill 0xDECC
	.fill 0xDED3
	.fill 0xDEDA
	.fill 0xDEDB
	.fill 0xDEE3
	.fill 0xDEEB
	.fill 0xDEF3
	.fill 0xDEF4

	# |
	.fill 0xDF0B
	.fill 0xDF13
	.fill 0xDF1B
	.fill 0xDF23
	.fill 0xDF2B
	.fill 0xDF33
	
	# }
	.fill 0xDF4A
	.fill 0xDF4B
	.fill 0xDF53
	.fill 0xDF5B
	.fill 0xDF5C
	.fill 0xDF63
	.fill 0xDF6B
	.fill 0xDF72
	.fill 0xDF73

	# ~
	.fill 0xDF9B
	.fill 0xDF9D
	.fill 0xDFA2
	.fill 0xDFA4

	text_tilemap_end:
	


# Data Section:

# Code Section:
write_solid_tile:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -10
	sw r3  r2  -1
	sw r4  r2  -2
	movi r3 TILEMAP_START
	lw r3  r3  0
	sw r3  r2  -3
	lw r3  r2  -3
	sw r3  r2  -4
	movi r3 64
	sw r3  r2  -5
	lw r3  r2  -5
	lw r4  r2  -1
	call umul
	sw r3  r2  -6
	lw r3  r2  -4
	lw r4  r2  -6
	add r3  r3  r4 
	sw r3  r2  -4
	movi r3 0
	sw r3  r2  -7
write_solid_tile.for.0.start:
	movi r3 1
	sw r3  r2  -8
	lw r3  r2  -7
	movi r4 64
	cmp r3  r4 
	bl 1
	jmp 3
	movi r3 write_solid_tile.end.6
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -8
write_solid_tile.end.6:
	lw r3  r2  -8
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 write_solid_tile.for.0.break
	jalr r0  r3 
	lw r3  r2  -7
	movi r4 1
	call smul
	sw r3  r2  -9
	lw r3  r2  -4
	lw r4  r2  -9
	add r3  r3  r4 
	sw r3  r2  -10
	lw r3  r2  -10
	lw r4  r2  -2
	sw r4  r3  0
write_solid_tile.for.0.continue:
	lw r3  r2  -7
	movi r4 1
	add r3  r3  r4 
	sw r3  r2  -7
	movi r3 write_solid_tile.for.0.start
	jalr r0  r3 
write_solid_tile.for.0.break:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
draw_pixel:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -43
	sw r3  r2  -1
	sw r4  r2  -2
	sw r5  r2  -3
	movi r3 FRAMEBUFFER_START
	lw r3  r3  0
	sw r3  r2  -4
	lw r3  r2  -4
	sw r3  r2  -5
	movi r3 2
	sw r3  r2  -6
	lw r3  r2  -1
	lw r4  r2  -6
	call udiv
	sw r3  r2  -7
	lw r3  r2  -7
	movi r4 1
	call umul
	sw r3  r2  -8
	lw r3  r2  -5
	lw r4  r2  -8
	add r3  r3  r4 
	sw r3  r2  -9
	movi r3 64
	sw r3  r2  -10
	lw r3  r2  -10
	lw r4  r2  -2
	call umul
	sw r3  r2  -11
	lw r3  r2  -11
	movi r4 1
	call umul
	sw r3  r2  -12
	lw r3  r2  -9
	lw r4  r2  -12
	add r3  r3  r4 
	sw r3  r2  -13
	lw r3  r2  -13
	lw r4  r3  0
	sw r4  r2  -14
	lw r3  r2  -14
	sw r3  r2  -15
	movi r3 1
	sw r3  r2  -16
	lw r3  r2  -1
	lw r4  r2  -16
	and r3  r3  r4 
	sw r3  r2  -17
	lw r3  r2  -17
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 draw_pixel.else.25
	jalr r0  r3 
	movi r3 2
	sw r3  r2  -18
	lw r3  r2  -1
	lw r4  r2  -18
	call udiv
	sw r3  r2  -19
	lw r3  r2  -19
	movi r4 1
	call umul
	sw r3  r2  -20
	lw r3  r2  -5
	lw r4  r2  -20
	add r3  r3  r4 
	sw r3  r2  -21
	movi r3 64
	sw r3  r2  -22
	lw r3  r2  -22
	lw r4  r2  -2
	call umul
	sw r3  r2  -23
	lw r3  r2  -23
	movi r4 1
	call umul
	sw r3  r2  -24
	lw r3  r2  -21
	lw r4  r2  -24
	add r3  r3  r4 
	sw r3  r2  -25
	movi r3 8
	sw r3  r2  -26
	lw r3  r2  -3
	lw r4  r2  -26
	call left_shift
	sw r3  r2  -27
	movi r3 255
	sw r3  r2  -28
	lw r3  r2  -15
	lw r4  r2  -28
	and r3  r3  r4 
	sw r3  r2  -29
	lw r3  r2  -27
	lw r4  r2  -29
	or r3  r3  r4 
	sw r3  r2  -30
	lw r3  r2  -25
	lw r4  r2  -30
	sw r4  r3  0
	movi r3 draw_pixel.end.39
	jalr r0  r3 
draw_pixel.else.25:
	movi r3 2
	sw r3  r2  -31
	lw r3  r2  -1
	lw r4  r2  -31
	call udiv
	sw r3  r2  -32
	lw r3  r2  -32
	movi r4 1
	call umul
	sw r3  r2  -33
	lw r3  r2  -5
	lw r4  r2  -33
	add r3  r3  r4 
	sw r3  r2  -34
	movi r3 64
	sw r3  r2  -35
	lw r3  r2  -35
	lw r4  r2  -2
	call umul
	sw r3  r2  -36
	lw r3  r2  -36
	movi r4 1
	call umul
	sw r3  r2  -37
	lw r3  r2  -34
	lw r4  r2  -37
	add r3  r3  r4 
	sw r3  r2  -38
	movi r3 255
	sw r3  r2  -39
	lw r3  r2  -3
	lw r4  r2  -39
	and r3  r3  r4 
	sw r3  r2  -40
	movi r3 65280
	sw r3  r2  -41
	lw r3  r2  -15
	lw r4  r2  -41
	and r3  r3  r4 
	sw r3  r2  -42
	lw r3  r2  -40
	lw r4  r2  -42
	or r3  r3  r4 
	sw r3  r2  -43
	lw r3  r2  -38
	lw r4  r2  -43
	sw r4  r3  0
draw_pixel.end.39:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
read_pixel:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -40
	sw r3  r2  -1
	sw r4  r2  -2
	movi r3 FRAMEBUFFER_START
	lw r3  r3  0
	sw r3  r2  -3
	lw r3  r2  -3
	sw r3  r2  -4
	movi r3 2
	sw r3  r2  -5
	lw r3  r2  -1
	lw r4  r2  -5
	call udiv
	sw r3  r2  -6
	lw r3  r2  -6
	movi r4 1
	call umul
	sw r3  r2  -7
	lw r3  r2  -4
	lw r4  r2  -7
	add r3  r3  r4 
	sw r3  r2  -8
	movi r3 64
	sw r3  r2  -9
	lw r3  r2  -9
	lw r4  r2  -2
	call umul
	sw r3  r2  -10
	lw r3  r2  -10
	movi r4 1
	call umul
	sw r3  r2  -11
	lw r3  r2  -8
	lw r4  r2  -11
	add r3  r3  r4 
	sw r3  r2  -12
	lw r3  r2  -12
	lw r4  r3  0
	sw r4  r2  -13
	lw r3  r2  -13
	sw r3  r2  -14
	movi r3 1
	sw r3  r2  -15
	lw r3  r2  -1
	lw r4  r2  -15
	and r3  r3  r4 
	sw r3  r2  -16
	lw r3  r2  -16
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 read_pixel.else.23
	jalr r0  r3 
	movi r3 2
	sw r3  r2  -17
	lw r3  r2  -1
	lw r4  r2  -17
	call udiv
	sw r3  r2  -18
	lw r3  r2  -18
	movi r4 1
	call umul
	sw r3  r2  -19
	lw r3  r2  -4
	lw r4  r2  -19
	add r3  r3  r4 
	sw r3  r2  -20
	movi r3 64
	sw r3  r2  -21
	lw r3  r2  -21
	lw r4  r2  -2
	call umul
	sw r3  r2  -22
	lw r3  r2  -22
	movi r4 1
	call umul
	sw r3  r2  -23
	lw r3  r2  -20
	lw r4  r2  -23
	add r3  r3  r4 
	sw r3  r2  -24
	lw r3  r2  -24
	lw r4  r3  0
	sw r4  r2  -25
	lw r3  r2  -25
	sw r3  r2  -26
	lw r3  r2  -26
	sw r3  r2  -27
	lw r3  r2  -27
	movi r4 8
	call right_shift
	sw r3  r2  -27
	lw r3  r2  -27
	sw r3  r2  -28
	lw r3  r2  -28
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
	movi r3 read_pixel.end.35
	jalr r0  r3 
read_pixel.else.23:
	movi r3 2
	sw r3  r2  -29
	lw r3  r2  -1
	lw r4  r2  -29
	call udiv
	sw r3  r2  -30
	lw r3  r2  -30
	movi r4 1
	call umul
	sw r3  r2  -31
	lw r3  r2  -4
	lw r4  r2  -31
	add r3  r3  r4 
	sw r3  r2  -32
	movi r3 64
	sw r3  r2  -33
	lw r3  r2  -33
	lw r4  r2  -2
	call umul
	sw r3  r2  -34
	lw r3  r2  -34
	movi r4 1
	call umul
	sw r3  r2  -35
	lw r3  r2  -32
	lw r4  r2  -35
	add r3  r3  r4 
	sw r3  r2  -36
	lw r3  r2  -36
	lw r4  r3  0
	sw r4  r2  -37
	lw r3  r2  -37
	sw r3  r2  -38
	lw r3  r2  -38
	sw r3  r2  -39
	lw r3  r2  -39
	movi r4 255
	and r3  r3  r4 
	sw r3  r2  -39
	lw r3  r2  -39
	sw r3  r2  -40
	lw r3  r2  -40
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
read_pixel.end.35:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 


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
