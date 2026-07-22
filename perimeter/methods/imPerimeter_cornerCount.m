function perim = imPerimeter_cornerCount(img)
%IMPERIMETER_CORNERCOUNT Perimeter of a binary region using corner count method.
%
%   P = imPerimeter_cornerCount(IMG)
%
%   Requires the Matlab's Image Processing Toolbox.
%
%   Example
%     R = 40;
%     img = discreteDisk(1:100, 1:100, [50.12 50.23 R]);
%     perim = imPerimeter_cornerCount(img)
%     pth = 2*pi*R;
%     error = 100 * (perim - pth) / pth
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-07-22,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.

props = regionprops(img, {'Perimeter'});
perim = props.Perimeter;
