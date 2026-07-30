%CHECKPERIMETER_BSPLINEPOLAR8_R40_00  One-line description here, please.
%
%   output = checkPerimeter_BSplinePolar8_R40_00(input)
%
%   Example
%   checkPerimeter_BSplinePolar8_R40_00
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-06-09,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.

% parameters of the shape
center = [50 50];
radius = 40;
nVertices = 8;
shapeName = 'BSplinePolar8_R40_00';

theta = linspace(0, 2*pi, nVertices+1)';
theta(end) = [];

% create a sample of the shape
rng(300);
dists = radius * rand(nVertices, 1);
verts = dists .* [cos(theta) sin(theta)] + center;
shape = BSplinePolygon2D(verts);
pth = perimeter(shape);

figure; hold on; axis equal; axis([0 100 0 100]);
drawPolygon(verts)
curve = BSplinePolygon2D(verts);
draw(curve, 'm')
