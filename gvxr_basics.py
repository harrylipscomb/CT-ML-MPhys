#!/usr/bin/env python3

# Import packages
import os
import numpy as np # Who does not use Numpy?

has_mpl = True
try:
    import matplotlib # To plot images
    import matplotlib.pyplot as plt # Plotting
    from matplotlib.colors import LogNorm # Look up table
    from matplotlib.colors import PowerNorm # Look up table

    font = {'family' : 'serif',
             'size'   : 15
           }
    matplotlib.rc('font', **font)

    # Uncomment the line below to use LaTeX fonts
    # matplotlib.rc('text', usetex=True)
except:
    has_mpl = False

# from tifffile import imwrite # Write TIFF files

from gvxrPython3 import gvxr # Simulate X-ray images

projections_number = 20.
angle = 360. / projections_number

# Create an OpenGL context
print("Create an OpenGL context")
gvxr.createOpenGLContext();

# Create a source
print("Set up the beam")
gvxr.setSourcePosition(0.0, 0.0, -40.0, "cm");
gvxr.usePointSource();
#  For a parallel source, use gvxr.useParallelBeam();

# Set its spectrum, here a monochromatic beam
# 1000 photons of 80 keV (i.e. 0.08 MeV) per ray
gvxr.setMonoChromatic(0.08, "MeV", 1000);
# The following is equivalent: gvxr.setMonoChromatic(80, "keV", 1000);

# Set up the detector
print("Set up the detector");
gvxr.setDetectorPosition(0.0, 0.0, 10.0, "cm");
gvxr.setDetectorUpVector(-1, 0, 0);
gvxr.setDetectorNumberOfPixels(800, 800);
gvxr.setDetectorPixelSize(0.5, 0.5, "mm");

# Locate the sample STL file from the package directory
fname = "harry.stl"


print("Load the mesh data from", fname);
gvxr.loadMeshFile("Dragon", fname, "mm")

print("Move ", "Dragon", " to the centre");
gvxr.moveToCentre("Dragon");

#gvxr.rotateNode("Dragon", 90, 0, 0, 1)

# Material properties
print("Set ", "Dragon", "'s material");

# Iron (Z number: 26, symbol: Fe)
gvxr.setElement("Dragon", 26)
gvxr.setElement("Dragon", "Fe")

# Liquid water
# gvxr.setCompound("Dragon", "C3H6")
# gvxr.setDensity("Dragon", 0.855, "g/cm3")
# gvxr.setDensity("Dragon", 0.855, "g.cm-3")

# Compute an X-ray image
# We convert the array in a Numpy structure and store the data using single-precision floating-point numbers.
print("Compute an X-ray image");
#x_ray_image = np.array(gvxr.computeProjectionSet(0,1,0, "cm", 20, 18)).astype(np.single)
gvxr.computeProjectionSet(0,2,0, "cm", projections_number, angle)
x_ray_image = np.array(gvxr.computeProjectionSet(0,2,0, "cm", projections_number, angle)).astype(np.single)
# Update the visualisation window
#gvxr.displayScene()


# Save the X-ray image in a TIFF file and store the data using single-precision floating-point numbers.
gvxr.saveLastProjectionSet('projection.tif',False)

for n in range(int(projections_number)):
    plt.figure(figsize=(10, 5))
    plt.title("Image simulated using gVirtualXray\nusing a linear colour scale")
    plt.imshow(x_ray_image[n], cmap="gray")
    plt.colorbar(orientation='vertical');
    plt.savefig('square'+str(n)+'.png')


#gvxr.renderLoop()
