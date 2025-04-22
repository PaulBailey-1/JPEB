# note that this follows the following ISA convensions
# r1 = stack pointer
# r7 = return link

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
  movi r3, 0x0100
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

  movi r5, 119 # 'w'
  cmp r3, r5 # 'w'
  bne NOTW
  movi r3, 0x00FF
  sw r3, r4, 0
  jmp NOTD
NOTW:
  movi r5, 97 # 'a'
  cmp r3, r5 # 'a'
  bne NOTA
  movi r3, 0xFF00
  sw r3, r4, 0
  jmp NOTD
NOTA:
  movi r5, 115 # 's'
  cmp r3, r5 # 's'
  bne NOTS
  movi r3, 0x0001
  sw r3, r4, 0
  jmp NOTD
NOTS:
  movi r5, 100 # 'd'
  cmp r3, r5 # 'd'
  bne NOTD
  movi r3, 0x0100
  sw r3, r4, 0
  jmp NOTD
NOTD:
LADVANCE_SNAKE:
  # load next position
  movi r4, DIRECTION
  lw r3, r4, 0
  # perform move
  movi r4, DATA
  lw r5, r4, 0 # r4 is the head of the snake
  add r2, r3, r0 # store the direction to determine carry bit
  add r3, r3, r5 # r3 will store next position 
  movi r6, 0x00FF # we use this to mask out carry bit
  and r5, r5, r6
  and r2, r2, r6
  add r5, r5, r2
  movi r6, 0x0100
  and r5, r5, r6 # 0x0100 if carry bit otherwise 0x0000
  sub r3, r3, r5

  movi r4, SNAKE_LENGTH
  lw r2, r4, 0
  movi r4, DATA
LMOVE_FORWARD:
  lw r5, r4, 0
  sw r3, r4, 0
  add r3, r0, r5
  addi r4, r4, 1
  addi r2, r2, -1
  sw r4, r0, 0
  sw r2, r0, 0
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
  lw r3, r4, 0
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
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
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

LOOP_COUNT: # the number of cycles to stall in the main loop
  .fill 40000
DIRECTION:
  .fill 0x0001
COLOR_STATE:
  .fill 2
DATA:
  .space 4800
APPLE:
  .fill 0x281e
SNAKE_LENGTH:
  .fill 2