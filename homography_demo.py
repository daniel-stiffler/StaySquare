# Anthony Kuntz
# 18-500 demo code
#
# Nothing tricky happening here, it's basically just PixelLab from 15122

import PIL as pil
from PIL import Image
import numpy as np

def apply_transformation(a,b,c,d,e,f,g,h,name):

    H = np.matrix([ [a, b, c],
                    [d, e, f],
                    [g, h, 1] ])


    source = Image.open(name)
    source_mat = np.array(source)

    dest = Image.new(source.mode, source.size)
    display = dest.load()

    width, height = dest.size

    for y in xrange(height):
        for x in xrange(width):

            dest_array = np.array([[x], [y], [1]])

            result = np.matmul(H,dest_array)

            x_src = min( width-1, max(0, int(round(result[0]))))
            y_src = min(height-1, max(0, int(round(result[1]))))

            display[y,x] = tuple(source_mat[y_src][x_src])

    dest.show()

# identity function: 
# apply_transformation(1,0,0,0,1,0,0,0,"icon.png")

apply_transformation(1,.2,.1,.1,1,0,0,0,"icon.png")




        

