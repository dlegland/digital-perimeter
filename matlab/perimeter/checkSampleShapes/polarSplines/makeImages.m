%MAKEIMAGES  One-line description here, please.
%
%   output = makeImages(input)
%
%   Example
%   makeImages
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-06-11,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.

if ~exist('png_images', 'dir')
    mkdir("png_images");
end

for i = 1:50
    inputDir = sprintf('polar8_%02d', i-1);
    fileName = sprintf('BSplinePolar8_R50_%d_stack.tif', i-1);
    img = imread(fullfile(inputDir, fileName));

    img2 = 255 - img;
    fileName2 = sprintf('BSplinePolar8_R50_%02d.png', i-1);
    imwrite(img2, fullfile('png_images', fileName2));
end
    
