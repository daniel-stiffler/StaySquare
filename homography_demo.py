# Anthony Kuntz
# 18-500 demo code
#
# Nothing tricky happening here, it's basically just PixelLab from 15122
#
# KEYSTONE CORRECTION DERIVED FROM THE PARAMETERS OF PROJECTORS
# https://patentimages.storage.googleapis.com/9e/8d/78/5056def0bb7426/US6997563.pdf
#
# VLSI ARCHITECTURE FOR ELECTRONIC CORRECTION OF OPTICAL DISTORTIONS
# http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.4.8788&rep=rep1&type=pdf
#
# FPGA ARCHITECTURE FOR REAL-TIME BARREL DISTORTION CORRECTION OF COLOUR IMAGES
# https://web.stanford.edu/~hblasins/Publications/ICME2011.pdf

import PIL as pil
from PIL import Image
import numpy as np
from math import cos, pi, sin, tan

""" Compute the Direct Linear Transform (DLT) and obtain the homography matrix
from the following steps:

    1. For each correspondence xi <-> xi', compute the first two rows of Ai
    2. Assemble n 2x9 matrices Ai into a single 2nx9 matrix A
    3. Obtain the singular value decomposition of A
    4. Solution for h is the eigenvector corresponding to the smallest
       eigenvalue of A.T A
    5. Determine H from h

    NOTE: According to one presentation I found, the algorithm implemented below
    might not be using the correct matrix for DLT... need to check this more """
def get_homography(proj_coors, screen_coors):
    if len(proj_coors) != 4 or not all(len(e) == 2 for e in proj_coors):
        raise ValueError("Arg `proj_coors` should be contain (x,y) for 4 " \
                         "coordinates in the projector space")

    if len(screen_coors) != 4 or not all(len(e) == 2 for e in screen_coors):
        raise ValueError("Arg `screen_coors` should be contain (X,Y) for 4 " \
                         "coordinates in the screen space")

    (x1, y1), (x2, y2), (x3, y3), (x4, y4) = proj_coors
    (X1, Y1), (X2, Y2), (X3, Y3), (X4, Y4) = screen_coors

    A = np.empty((2 * 4, 9), dtype=np.float64)

    A[0, :] = X1, Y1, 1, 0, 0, 0, -X1 * x1, -Y1 * x1, -x1
    A[1, :] = 0, 0, 0, X1, Y1, 1, -X1 * y1, -Y1 * y1, -y1
    A[2, :] = X2, Y2, 1, 0, 0, 0, -X2 * x2, -Y2 * x2, -x2
    A[3, :] = 0, 0, 0, X2, Y2, 1, -X2 * y2, -Y2 * y2, -y2
    A[4, :] = X3, Y3, 1, 0, 0, 0, -X3 * x3, -Y3 * x3, -x3
    A[5, :] = 0, 0, 0, X3, Y3, 1, -X3 * y3, -Y3 * y3, -y3
    A[6, :] = X4, Y4, 1, 0, 0, 0, -X4 * x4, -Y4 * x4, -x4
    A[7, :] = 0, 0, 0, X4, Y4, 1, -X4 * y4, -Y4 * y4, -y4

    AtA = np.dot(A.T, A)

    eigenvals, eigenvecs = np.linalg.eigh(AtA)

    for i in range(len(eigenvals)):
        print("Eigenvalue: {} Eigenvector: {}".format(eigenvals[i],
                                                      eigenvecs[:, i]))

    smallest_idx = np.argmin(eigenvals)
    small_val = eigenvals[smallest_idx]
    small_vec = eigenvecs[:, smallest_idx]

    H = small_vec.reshape((3, 3))

    print("Homography matrix:\n{}".format(H))

    return H

""" Some projectors achieve rotation by elevating the front end of the
projector: either using extendible legs, or by propping the projector, perhaps
using books.  This elevation accomplishes rotation through the vertical
YZ-plane. To achieve rotation through the horizontal plane, the projector (along
with any elevating materials) is swiveled on the table (or whatever surface the
projector is resting on). In other words, the horizontal rotation is in the
original XZ-plane, which was orthogonal to the projection surface. """
def proj_corners1(x, y, d, vert_tilt, horiz_tilt, offset, width=1920,
                  height=1080):

    x_proj_numer = cos(horiz_tilt) * x
    x_proj_denom = 1. + \
                   (sin(vert_tilt) * y + cos(vert_tilt) * sin(horiz_tilt) * x) / d
    x_proj = x_proj_numer / x_proj_denom

    y_proj_numer = cos(vert_tilt) * y - \
                   sin(horiz_tilt) * sin(vert_tilt) * x - \
                   (offset - height/2)
    y_proj_denom = 1 + \
                   (sin(vert_tilt) * y + cos(vert_tilt) * sin(horiz_tilt) * x) / d ** 6
    y_proj = y_proj_numer / y_proj_denom + (offset - width/2)

    return x_proj, y_proj

""" Some projectors using a platform that can both rotate left and right and
swivel up and down. Such a projector is not performing rotation in the original
XZ-plane: instead, it is rotating horizontally in a tilted plane. Thus, to
determine the “true” horizontal rotation (relative to the original XZ plane)
requires compensating for the fact that the projector has also been tilted
vertically. """
def proj_corners2(x, y, d, vert_tilt, horiz_tilt, offset, width=1920,
                  height=1080):

    x_proj_numer = cos(horiz_tilt) * x - \
                   sin(horiz_tilt) * cos(vert_tilt) * y
    x_proj_denom = 1 + \
                   (sin(horiz_tilt) * x - cos(horiz_tilt) * sin(vert_tilt) * y) / d
    x_proj = x_proj_numer / x_proj_denom

    y_proj_numer = cos(vert_tilt) * y - \
                   (offset - width/2)
    y_proj_denom = 1 + \
                   (sin(horiz_tilt) * x + cos(horiz_tilt) * sin(vert_tilt) * y) / d
    y_proj = y_proj_numer / y_proj_denom + (offset - height/2)

    return x_proj, y_proj

""" Transform a pair (xp, yp) of undistorted coordinates into the corresponding
pair (xk, yk) in the plane of the tilted screen. """

def vertical_tilt(xp, yp, depth, alpha_v):
    # Calculate the distorted coordinates in 3d-space, not accounting for the
    # varying depth of the screen with respect to the lens
    xk = xp / (1 - (yp / depth) * tan(alpha_v))
    yk = yp / (1 - (yp / depth) * tan(alpha_v))
    zk = yp * tan(alpha_v) / (1 - (yp / depth) * tan(alpha_v))

    # Perform the same calculation as before, but now transform the coordinates
    # from the original system into the coordinate system of hte tilted screen
    # by applying a rotation matrix
    #
    # Rv = [[1, 0,          0],
    #       [0, cos(alpha_v), -sin(alpha_v)],
    #       [0, sin(alpha_v), cos(alpha_v)]]
    xk_prime = xp * cos(alpha_v) / (cos(alpha_v) - (yp / depth) * sin(alpha_v))
    yk_prime = yp / (cos(alpha_v) - (yp / depth) * sin(alpha_v))
    zk_prime = 0 # Necessary condition, as the screen is a plane

    return (xk, yk, zk), (xk_prime, yk_prime, zk_prime)

def both_tilt(xp, yp, depth, alpha_h, alpha_v):
    # Calculate the distorted coordinates in 3d-space, not accounting for the
    # varying depth of the screen with respect to the lens
    xk_numer = xp
    xk_denom = 1 - \
               (xp / depth) * tan(alpha_h) - \
               (yp / depth) * tan(alpha_v) / cos(alpha_h)
    xk = xk_numer / xk_denom

    yk_numer = yp
    yk_denom = 1 - \
               (xp / depth) * tan(alpha_h) - \
               (yp / depth) * tan(alpha_v) / cos(alpha_h)
    yk = yk_numer / yk_denom

    zk_numer = depth
    zk_denom = 1 - \
               (xp / depth) * tan(alpha_h) - \
               (yp / depth) * tan(alpha_v) / cos(alpha_h)
    zk = -depth + zk_numer / zk_denom

    # Perform the same calculation as before, but now transform the coordinates
    # from the original system into the coordinate system of hte tilted screen
    # by applying a rotation matrix
    #
    # Rv = [[1, 0,          0],
    #       [0, cos(alpha_v), -sin(alpha_v)],
    #       [0, sin(alpha_v), cos(alpha_v)]]
    #
    # Rh = [[cos(alpha_h), 0, -sin(alpha_h)],
    #       [0,            1, 0],
    #       [sin(alpha_h), 0, cos(alpha_h)]]
    xk_prime_numer = xp * cos(alpha_v) + \
                     yp * sin(alpha_v) * sin(alpha_h)
    xk_prime_denom = cos(alpha_v) * cos(alpha_h) - \
                     (xp / depth) * cos(alpha_v) * sin(alpha_h) - \
                     (yp / depth) * sin(alpha_v)
    xk_prime = xk_prime_numer / xk_prime_denom

    yk_prime_numer = yp * cos(alpha_h)
    yk_prime_denom = cos(alpha_v) * cos(alpha_h) - \
                     (xp / depth) * cos(alpha_v) * sin(alpha_h) - \
                     (yp / depth) * sin(alpha_v)
    yk_prime = yk_prime_numer / yk_prime_denom
    zk_prime = 0 # Necessary condition, as the screen is a plane

    return (xk, yk, zk), (xk_prime, yk_prime, zk_prime)

def clamp(x, lo, hi):
    if x < lo: return int(lo + 0.5)
    elif x > hi: return int(hi + 0.5)
    else: return int(x + 0.5);

def apply_transformation(H, name):

    source = Image.open(name)
    source_mat = np.array(source)

    dest = Image.new(source.mode, source.size)
    width, height = dest.size
    display = dest.load()

    for y in range(height):
        for x in range(width):
            # Homogenous image coordinate
            screen_coor = np.array([[x], [y], [1]])

            mapped_coor = H @ screen_coor

            #  print("Inhomogeneous mapping:\n{}".format(mapped_coor))
            w = mapped_coor[2, 0]
            mapped_coor = mapped_coor / w
            #  print("Homogeneous mapping:\n{}".format(mapped_coor))

            xp = clamp(mapped_coor[0, 0], 0, width-1)
            yp = clamp(mapped_coor[1, 0], 0, height-1)
            zp = mapped_coor[2, 0]

            display[y, x] = tuple(source_mat[yp, xp])

    dest.save(name + "_H", "PNG")

def main():
    np.set_printoptions(precision=2, threshold=25, suppress=True)

    depth = 1000
    alpha_v = pi / 6
    proj_coors = [
            (0, 0), (0, 640),
            (480, 0), (640, 480),
            ]

    screen_coors = []
    for xp, yp in proj_coors:
        #  xyz, (xk_prime, yk_prime, _) = vertical_tilt(xp, yp, depth, alpha_v)
        xyz, (xk_prime, yk_prime, _) = both_tilt(xp, yp, depth, alpha_v, alpha_v)
        print("Calculated mapping ({}, {})->({}, {})".format(xp, yp, xk_prime,
                                                             yk_prime))

        screen_coors.append((xk_prime, yk_prime))

    H = get_homography(proj_coors, screen_coors)
    H_inv = np.linalg.inv(H)
    apply_transformation(H_inv, "icon.png")

if __name__ == "__main__":
    main()

# identity function:
# apply_transformation(1,0,0,0,1,0,0,0,"icon.png")

#  apply_transformation(1,.2,.1,.1,1,0,0,0,"icon.png")


