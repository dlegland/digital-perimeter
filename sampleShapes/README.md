# Sample Shapes

This directory contains a collection of Matlab scripts for generating discrete images
of sample shapes with various degrees of complexity.

## Shapes

Discrete images of the following shapes can be generated:

* **disk**. Value in file name correspond to radius.
* **square**. Value in file name correspond to side length.
* **ellipse**. Values in file name correspond to length of major and minor semi-axes.
* **lune**: obtained as the difference between two disks with same radius (useful for checking non-convex shapes). 
Values in file name correspond to disk radius and distance between centers.
* **trefoil**: a polar curve obtained from a sinusoidal curve with a period equal to three.
Values in file name correspond to outer and inner radius.
* **starfish**: a polar curve obtained from a sinusoidal curve with a period equal to five
Values in file name correspond to outer and inner radius.

Other shapes may be added in the future.


## Contents

The "**createImages_XXX.m**" files generate a series of images for the specified shape, and store
the resulting images within the "images" directory as tiff stacks, with as many slice images 
as the number of random realizations. 
The position and the orientation of the shapes are saved in a text file within the "params"
directory.

The "**images/**" directory is intentionnally not included within the git repository.
Its content can be either generated from the Matlab scripts, or retrieved from Zenodo.

Some files correspond to Matlab classes that are used for generating discrete versions of
non-trivial geometries:

* **StarFish2D.m**
* **Trefoil2D.m**
* **BSplinePolygon2D.m**: a smooth shape obtained by interpolating the vertex coordinates of a 
polygon.


## Requirements

The image generation scripts require [the MatGeom library](https://github.com/mattools/matGeom),
as well as [the MatImage library](https://github.com/mattools/matImage) 
(for the generation of generation of phantom image and the export as tiff stacks).
