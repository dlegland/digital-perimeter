function perim = imPerimeter_boundaryPolygon(img)
%IMPERIMETER_BOUNDARYPOLYGON Perimeter of a binary region from boundary polygon.
%
%   P = imPerimeter_boundaryPolygon(IMG)
%
%   Requires the MatGeom and the MatImage libraries.
%
%   Example
%     R = 40;
%     img = discreteDisk(1:100, 1:100, [50.12 50.23 R]);
%     perim = imPerimeter_boundaryPolygon(img)
%     pth = 2*pi*R;
%     error = 100 * (perim - pth) / pth
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-10-04,    using Matlab 9.14.0.2206163 (R2023a)
% Copyright 2023 INRAE.

polys = imBoundaryContours(img);

perim = 0;
for i = 1:length(polys)
    perim = perim + polygonLength(polys{i});
end

