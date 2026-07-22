function perim = imPerimeter_boundaryPixelCount(img, varargin)
%IMPERIMETER_BOUNDARYPIXELCOUNT  One-line description here, please.
%
%   output = imPerimeter_boundaryPixelCount(input)
%
%   Example
%     R = 40;
%     img = discreteDisk(1:100, 1:100, [50.12 50.23 R]);
%     perim = imPerimeter_boundaryPixelCount(img)
%     pth = 2*pi*R;
%     error = 100 * (perim - pth) / pth
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-10-03,    using Matlab 9.14.0.2206163 (R2023a)
% Copyright 2023 INRAE.

conn = 4;
if ~isempty(varargin)
    conn = varargin{1};
end

if conn == 4
    se = [0 1 0;1 1 1;0 1 0];
elseif conn == 8
    se = ones(3,3);
else
    error('Unkown connectivity: %d', conn);
end

% identify boundary pixels
imgBnd = imerode(img, se) ~= img;

perim = sum(sum(imgBnd));