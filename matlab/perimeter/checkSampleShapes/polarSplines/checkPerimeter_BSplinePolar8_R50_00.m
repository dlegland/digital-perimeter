%CHECKPERIMETER_BSPLINEPOLAR8_R50_00  One-line description here, please.
%
%   output = checkPerimeter_BSplinePolar8_R50_00(input)
%
%   Example
%   checkPerimeter_BSplinePolar8_R50_00
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
radius = 50;
nVertices = 8;
shapeName = 'BSplinePolar8_R50_01';

theta = linspace(0, 2*pi, nVertices+1)';
theta(end) = [];

% create a sample of the shape
rng(1);
dists = radius * rand(nVertices, 1);
verts = dists .* [cos(theta) sin(theta)] + center;
shape0 = BSplinePolygon2D(verts);
pth = perimeter(shape0);

figure; hold on; axis equal; axis([0 100 0 100]);
drawPolygon(verts)
curve = BSplinePolygon2D(shape0);
draw(shape0, 'm')

% size of digitized image
dims = [100 100];

% discretization parameters
lx = 1:100;
ly = 1:100;
[x, y] = meshgrid(lx, ly);

% number of free parameters:
% two center coords + one orientation
nParams = 3;
nMethods = 3;

% allocate memory for storing simulation results
nSimuls = 100;
params = zeros(nSimuls, 3);
resCrofton2 = zeros(nSimuls, 1);
resCrofton4 = zeros(nSimuls, 1);
resMatlab   = zeros(nSimuls, 1);

stack = zeros([dims nSimuls], 'uint8');


%% Main iteration

% iterate over simulations
for iSimul = 1:nSimuls
    fprintf('.');
    if mod(iSimul, 20) == 0
        fprintf(' %4d/%d\n', iSimul, nSimuls);
    end
    
    % generate random parameters
    shift = rand(1,2);
    theta = rand * 180;
    params(iSimul,:) = [center theta];

    % generate discrete image of the shape
    shape = translate(rotate(shape0, theta, [50 50]), shift);
    poly = asPolyline(shape, 1000);
    img = reshape(isPointInPolygon([x(:) y(:)], poly), [100 100]);

    % keep image
    stack(:,:,iSimul) = img * 255;

    % measure perimeter using various methods
    resCrofton2(iSimul) = imPerimeter(img, 2);
    resCrofton4(iSimul) = imPerimeter(img, 4);
    props = regionprops(img, 'Perimeter');
    resMatlab(iSimul) = props.Perimeter;
end

%% Post-processing

% save table of position + orientation
tabParams = Table(params, {'ShiftX', 'ShiftY', 'Rotation'});
write(tabParams, sprintf('params_%s.txt', shapeName));

% save table of perimeter measurements (including reference perimeter)
colNames = {'Crofton2', 'Crofton4', 'Matlab', 'MatlabPi'};
perims = [resCrofton2 resCrofton4 resMatlab (resMatlab+pi)];
tabPerims = Table([pth(ones(nSimuls,1)), perims], [{'Reference'} colNames]);
write(tabPerims, sprintf('perimeter_%s.txt', shapeName));

% compute relative errors
errors = 100 * (perims - pth) / pth;
tabErrors = Table(errors, colNames);
write(tabErrors, sprintf('perimeter_%s_errors.txt', shapeName));

% summary of relative errors
tabStats = [mean(tabPerims(:,2:end))' mean(tabErrors)'  std(tabErrors)'];
write(tabStats, sprintf('perimeter_%s_summary.txt', shapeName));
disp(tabStats)


savestack(stack, sprintf('%s_stack.tif', shapeName));

