# Sample Shapes

This directory contains a collection of Matlab scripts for generating discrete images
of sample shapes with various degrees of complextity.

## File content

The "createImages_XXX" files generate a series of images for the specified shape, and store
the resulting images within the "images" directory as tiff stacks with as many slice images 
as the number of random realizations. 
The position and the orientation of the shapes are saved in a text file within the "params"
directory.

Some files correspond to Matlab classes that are used for generating discrete versions of
non-trivial geometries:

* StarFish2D: a polar curve obtained from a sinusoidal curve with a period equal to five.
* Trefoil2D: a polar curve obtained from a sinusoidal curve with a period equal to three.
