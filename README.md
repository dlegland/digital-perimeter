[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22010635.svg)](https://doi.org/10.5281/zenodo.22010635)

# Digital perimeter

A collection of scripts for investigating the precision and accuracy of methods for measuring the perimeter of regions within binary digital images.
The results obtained with different methods and software are compared to actual values. This allows for identifying which methods are the most suitable.

Investigated methods are:

* boundary polygon perimeter (easy to compute but biased)
* Crofton perimeter (more accurate)
* corner-count method (more precise)
* ImageJ "Analyze Particles" results (popular software)

## File organization


The **sampleShapes** directory contains (Matlab) scripts for generating synthetic binary images of geometric shapes
(disks, squares, ellipses...) with various sizes, positions and rotations.
Images are saved within sub-directories, but are not included in source control.
They can be found on Zenodo (https://doi.org/10.5281/zenodo.22009959)

The **imagej** directory contains java code for computing perimeter using ImageJ, either based on the 
"Analyze particles" feature, or using the [MorphoLibJ library](https://github.com/ijpb/MorphoLibJ). 
Results tables are located in the "tables" sub-directory.

The **matlab** directory contains scripts for measuring perimeter of synthetic shapes, 
comparing to expected value, and plotting the results.
