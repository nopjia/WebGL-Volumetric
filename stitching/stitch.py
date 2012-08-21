import array
from PIL import Image

SLICES = 361
size = (100, 100, 100)
imout = Image.new("L", (size[0], size[1]*size[2]))

for i in range(size[2]):
    z = i * SLICES/size[2]
    
    filename = "bunny/"+str(z+1)+".png"
    im = Image.open(filename)
    im = im.resize((110, 110))
    
    region = im.crop((3, 7, 103, 107))
    
    box = (0, i*size[1], size[0], (i+1)*size[1])
    imout.paste(region, box)
    
    print "processed slice "+str(z)+" : "+filename
    
imout.save("test.png", "PNG")