# Image analysis metrology

Investigation of precision and accuracy of measurement of perimeter from binary digital images 
by comparing results obtained with different methods and software.

Investigated methods are:

* boundary polygon perimeter (easy to compute but biased
* Crofton perimeter (more accurate)
* corner-count method (more precise)
* ImageJ "Analyze Particles" results (popular software)

## File organization

The **imagej** directory contains java code for computing perimeter using ImageJ, either based on the 
"Analyze particles" feature, or using the MorphoLibJ library. 
Results tables are located in the "tables" sub-directory.

The **matlab** directory contains scripts for generating synthetic binary imges of geometric shapes, 
measuring perimeter, and plotting the results.
