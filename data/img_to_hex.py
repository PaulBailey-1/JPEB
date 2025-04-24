from PIL import Image
from os import path
import sys

def read_and_process_sprites(file_path, to_keep):
    # Open the image
    img = Image.open(file_path)
    img = img.convert("RGB")  # Ensure the image is in RGB format

    sprite_width, sprite_height = img.width//3, img.height//1
    sprites = []

    # Extract each sprite
    for j in range(1):
        for i in range(3):  # 8 sprites in a row
            sprite = img.crop((i*sprite_width, j*sprite_height, (i+1)*sprite_width, (j+1)*sprite_height))

            transparent = sprite.getpixel((0,0))
            
            # print(i,j)
            for x in range(32):
                for y in range(32):
                    pixel = sprite.getpixel((x,y))
                    if pixel == transparent:
                        print("FFFF")
                    else:
                        print(f"0{pixel[0]//16:01X}{pixel[0]//16:01X}{pixel[0]//16:01X}")
            # print(arr.shape)
            sprites.append(sprite)

    for i in to_keep:
        sprites[i].show()

if __name__ == "__main__":
    import sys
    image = sys.argv[1]
    read_and_process_sprites(path.join(path.dirname(__file__), image), [0,1,2])