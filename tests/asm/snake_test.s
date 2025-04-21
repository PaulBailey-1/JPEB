# note that this follows the following ISA convensions
# r1 = stack pointer
# r7 = return link

PRESS_SPACE_TO_START:
  movi r4, 0xFFFF
  lw r4, r4, 0
  movi r3, 0x20
  cmp r4, r3
  bne PRESS_SPACE_TO_START

INIT:
  # color the entire background to green (4)
  movi r3, 0x0404
  movi r5, 0x1000
LBACKGROUND_INIT:
  addi r5, r5, -1
  movi r4, 0xE000
  add r4, r4, r5
  sw r3, r4, 0
  cmp r5, r0
  bnz LBACKGROUND_INIT
LAPPLE_INIT:
  # push previous return address
  push r7
  call FGROW_APPLE
  pop r7
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
  addi r3, r3, -1
  sw r3, r4, 0
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
  sw r6, r0, 0
  sw r3, r0, 0
  movi r5, 0xFEFF
  and r6, r6, r5 # mask to see if 0
  cmp r6, r0
  bz LCLEAR_SNAKE # going in reversed direction
  sw r3, r4, 0
LCLEAR_SNAKE:
  # clear snake for redrawing
  movi r4, COLOR_STATE
  movi r3, 4
  sw r3, r4, 0
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
  # generate apple
  push r7
  call FGROW_APPLE
  pop r7
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

# places the apple in a location on-screen different from originally and not occupied by the snake
# preserves all registers
FGROW_APPLE:
  push r2
  push r3
  push r4
  push r5
  push r6
LGROW_LOOP:
  # generate a new random location for apple x-location
  movi r3, 0x50
  push r7
  call FRANDOM
  pop r7
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  push r3
  # generate a new random location for apple y-location
  movi r3, 0x3c
  push r7
  call FRANDOM
  pop r7
  pop r5
  add r5, r5, r3
  movi r2, SNAKE_LENGTH
  lw r2, r2, 0
LNOTSNAKE_CHECK:
  addi r2, r2, -1
  movi r4, DATA
  add r4, r2, r2
  lw r3, r4, 0  # location of snake body part
  cmp r3, r5
  beq LGROW_LOOP # regenerate
  cmp r2, r0
  bne LNOTSNAKE_CHECK # check next part of snake
  movi r4, COLOR_STATE # set color
  sw r0, r4, 0
  movi r4, APPLE
  sw r5, r4, 0  # set apple location in memory to r5
  add r4, r5, r0
  push r7
  call FCOLOR_APPLE
  pop r7
  pop r6
  pop r5
  pop r4
  pop r3
  pop r2
  jalr r0, r7

FMODULO:
LMODULO_LOOP:
  cmp r3, r4       # compare r3 (dividend) with r4 (divisor)
  bl LMODULO_END  # if r3 < r4, exit loop
  sub r3, r3, r4   # subtract r4 from r3
  jmp LMODULO_LOOP # repeat
LMODULO_END:
  jalr r0, r7      # return

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
  call FMODULO
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

FEND:
  movi r4, 0xFFFF
LEND_LISTEN:
  lw r3, r4, 0
  cmp r3, r0
  bz LEND_LISTEN
  movi r4, INIT
  jalr r0, r4
  sys EXIT