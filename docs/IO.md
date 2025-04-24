# I/O

Our I/O consists of a PS/2 keyboard input and a VGA output. See the [memory map](https://github.com/PaulBailey-1/JPEB/blob/main/docs/mem_map.md) for info on what addresses these are at.  

## PS/2
Scan codes from the PS/2 keyboard are converted to ascii codes in hardware, and then buffered to be read from.

## VGA

### Framebuffer/Tilemap

We use 640 x 480 resolution. Because we can't store 640 x 480 = 307,200 pixels, we use a tilemap to avoid losing too much resolution.
We use 8 x 8 tiles and support up to 128 tiles at a time. This cuts our framebuffer size to 80 x 60 = 4800 tiles. However, we only need 7 bits to specify a tile, and each memory address contains 16 bits. To save address space, we put two tiles in each memory address, meaning the tilemap only requires 40 x 60 = 2400 entries.

### Scroll Registers

With only a framebuffer and tilemap, continuous motion becomes impossible. To move the background continuously, we add two scroll registers - a vertical scroll and horizontal scroll. The entire display will be shifted by the value stored in these registers. 

### Scale Register

To allow the size of the tiles to be changed, we have a resolution register. With a value of 0, we use the maximum resolution. With a value of 1, we now display each 8 x 8 tile as a 16 x 16 tile, by turning pixels into 2 x 2 blocks of pixels. This allows us to easily display larger text. Each time the scale register is incremented, resolution is halved.

### Sprites

To allow objects to move continuously against the background, we support 8 hardware sprites. 
