#!/usr/bin/env python

import array
from PIL import Image

size = (512, 512, 361)
#im = Image.new("L", (size[0], size[1]*size[2]))
im = Image.new("L", (size[0], size[1]))
putpix = im.im.putpixel

for z in range(151, size[2]):
        
    filename = "bunny/"+str(z+1)
    a = array.array("H")
    with open(filename, "rb") as f:
        a.fromfile(f, size[0]*size[1])
    a.byteswap()
    
    for y in range(size[1]):
        for x in range(size[0]):
            val = a[x+y*size[1]] / 16
            if val > 255:
                val = 0
            putpix((x,y), val)
            #putpix((x,y+z*size[1]), val)
            
    
        
    im.save(filename+".png", "PNG")
    
    print "processed slice "+str(z)+" : "+filename