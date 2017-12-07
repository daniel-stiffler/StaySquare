from math import cos, pi, sin, tan

from optparse import OptionParser
import numpy as np
import PIL as pil
from PIL import Image
import os.path

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

""" Transform a pair (xp, yp) of undistorted coordinates into the corresponding
pair (xk, yk) in the plane of the tilted screen. """
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

def apply_transformation(H, fname, width, height):
    fin_path = os.path.join("images", fname)
    fout_path = os.path.join("images",
                             "trans_{}.png".format(os.path.splitext(fname)[0]))

    # Setup source image
    src_img = Image.open(fin_path).convert("RGB").resize((width, height))
    if src_img.size != (width, height):
        print("Input image {} had unexpected dimensions " \
              "{}".format(fname, src_img.size))

    src_pixels = src_img.load() # Fast pixel access object [x, y]

    # Setup dest image
    dest_img = Image.new("RGB", (width, height))
    dest_pixels = dest_img.load() # Fast pixel access object [x, y]

    srcr = ""
    srcg = ""
    srcb = ""

    ansr = ""
    ansg = ""
    ansb = ""

    # Extend the dimension *2 in each dimension
    for y in range(0, height):
        for x in range(0, width):

            srcr = srcr + "%x\n" % src_pixels[x, y][0]
            srcb = srcb + "%x\n" % src_pixels[x, y][1]
            srcg = srcg + "%x\n" % src_pixels[x, y][2]

            # Homogeneous screen coordinate
            screen_coord = np.array([[x], [y], [1.]])

            screen_coord[0] -= width/2
            screen_coord[1] -= height/2

            # Map the homogeneous coordinate to the corresponding
            # non-homogeneous coordinate in the input plane
            mapped_coord = np.matmul(H,screen_coord)

            w = mapped_coord[2, 0] # Inhomogeneity
            mapped_coord = mapped_coord / w # Convert to homogeneous

            xp = int(round(mapped_coord[0, 0]))
            yp = int(round(mapped_coord[1, 0]))

            xp += width/2
            yp += height/2

            if 0 <= xp < width and 0 <= yp < height:
                dest_pixels[x, y] = src_pixels[xp, yp]
            else:
                dest_pixels[x, y] = (255, 255, 255) # Black

            if 0 <= xp < width and 0 <= yp < height:
                ansr = ansr + "%x\n" % src_pixels[xp, yp][0]
                ansb = ansb + "%x\n" % src_pixels[xp, yp][1]
                ansg = ansg + "%x\n" % src_pixels[xp, yp][2]
            else:
                ansr = ansr + "FF\n"
                ansg = ansg + "FF\n"
                ansb = ansb + "FF\n"

    f = open('rtl/r_source.hex','w')
    f.write(ansr)
    f.close()
    f = open('rtl/g_source.hex','w')
    f.write(ansg)
    f.close()
    f = open('rtl/b_source.hex','w')
    f.write(ansb)
    f.close()

    print len(ansr.split()), len(ansg.split()), len(ansb.split())
    f = open('rtl/r_answer.hex','w')
    f.write(ansr)
    f.close()
    f = open('rtl/g_answer.hex','w')
    f.write(ansg)
    f.close()
    f = open('rtl/b_answer.hex','w')
    f.write(ansb)
    f.close()

    dest_img.save(fout_path)
    print("Saved transformed image to {}".format(fout_path))

def main():
    parser = OptionParser()
    parser.add_option("-f", "--file", dest="fname", help="Input image name",
                      default="new_grad_hdmi.png")
    parser.add_option("--width", dest="width", help="Input image width",
                      default=1920)
    parser.add_option("--height", dest="height", help="Input image height",
                      default=1080)
    parser.add_option("-d", "--depth", dest="depth",
                      help="Project depth (imaginary units)", default=1000)
    parser.add_option("--vtilt", dest="alpha_v", help="Vertical tilt",
                      type=float, default=-pi/12.)
    parser.add_option("--htilt", dest="alpha_h", help="Horizontal tilt",
                      type=float, default=0.)

    options, args = parser.parse_args()

    width = options.width
    height = options.height
    depth = options.depth
    alpha_v = options.alpha_v
    alpha_h = options.alpha_h

    # Corners of our imaginary image in pixel coordinates relative to the center
    proj_coors = [
            (-width/2. - 1., -width/2. - 1.), (width/2., -width/2. - 1.),
            (-width/2. - 1, width/2.), (width/2., width/2.),
            ]

    screen_coors = []
    # For each coordinate in `proj_coors`, determine its mapping to the screen
    # using one of the appropriate functions
    for xp, yp in proj_coors:
        xyz, (xk_prime, yk_prime, _) = both_tilt(xp, yp, depth,
                                                 alpha_h, alpha_v)
        print("Calculated mapping ({}, {})->({}, {})".format(xp, yp, xk_prime,
                                                             yk_prime))

        screen_coors.append((xk_prime, yk_prime))

    H = get_homography(proj_coors, screen_coors)
    H_inv = np.linalg.inv(H) # Reverse the mapping for debugging purposes

    apply_transformation(H, "new_grad_hdmi.png", width, height)

if __name__ == "__main__":
    # Make printing more reasonable
    np.set_printoptions(precision=2, threshold=25, suppress=True)

    main()
