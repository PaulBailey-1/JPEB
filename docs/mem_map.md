# Memory Map

## 0x0000 - 0x9FFF:  
Code, heap, stack  
Code will start at 0x0000, stack at 0x9FFF  
heap is everything in between

## 0xA000 - 0xBFFF:  
Sprite data. Each sprite is 32x32 pixels, and we reserve space for 8.
If there's an overlap, the higher sprite will appear on top (sprite 7 over sprite 0).

## 0xC000 - 0xDFFF:  
Tilemap. Each tile is 8x8 pixels, and we reserve space for 128

## 0xE000 - 0xEFFF:
Framebuffer. Each entry contains two tiles. The plan is to use 640x480 resolution, so we need 4800 tiles = 2400 entries.

## 0xF000 - 0xFFFF:  
Other I/O.

## 0xFFE0 - 0xFFEF:
Sprite Coordinates.
Sprite 0 `x` coordinate at 0xFFE0, `y` coordinate at 0xFFE1,  
Sprite 1 `x` coordinate at 0xFFE2, and so on.

## 0xFFFC
Scale register (all screen items are displayed at 2\*\*n)

## 0xFFFD
Horizontal scroll register (in pixels)

## 0xFFFE
Vertical scroll register (in pixels)

## 0xFFFF
Input stream (0 if nothing, otherwise ASCII)
