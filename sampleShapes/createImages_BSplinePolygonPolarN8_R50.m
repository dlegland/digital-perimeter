function createImages_BSplinePolygonPolarN8_R50(varargin)
%CREATEIMAGES_BSPLINEPOLARPOLYGONN8_R50  One-line description here, please.
%
%   output = createImages_BSplinePolygonPolarN8_R50(input)
%
%   Example
%   createImages_BSplinePolygonPolarN8_R50
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-08-17,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE.


%% Global constants

% shape meta-parameters
center = [50 50];
radius = 50;
nVertices = 8;

% size of digitized 2D images
dims = [100 100];

% number of random shapes
nShapes = 50;

% number of simulations
nSimuls = 1000;


%% Initializations

% create polar basis
theta = linspace(0, 2*pi, nVertices+1)';
theta(end) = [];

% discretization parameters
lx = 1:100;
ly = 1:100;
[x, y] = meshgrid(lx, ly);

% allocate memory for result image stack
stack = zeros([dims nSimuls], 'uint8');

% check output directories exist
imagesOutputDir = fullfile('images', 'bsplinePolygonPolarN8_R50');
paramsOutputDir = fullfile('params', 'bsplinePolygonPolarN8_R50');
if ~exist(imagesOutputDir, 'dir')
    mkdir(imagesOutputDir);
end
if ~exist(paramsOutputDir, 'dir')
    mkdir(paramsOutputDir);
end

% generate random position and orientation for each realization
shifts = rand(nSimuls,2);
angles = rand(nSimuls,1) * 180;
angles = sort(angles);
params = [shifts angles];

% save table of position + orientation
tabParams = Table(params, {'ShiftX', 'ShiftY', 'Rotation'});
paramFileName = sprintf('shape_positions.txt');
write(tabParams, fullfile(paramsOutputDir, paramFileName));


%% Main iteration

% iterate over shapes
for iShape = 1:nShapes
    shapeName = sprintf('BSplinePolygonPolar%d_R50_%02d', nVertices, iShape-1);
    fprintf('process shape %d/%d (%s)\n', iShape, nShapes, shapeName);

    % create a sample of the shape
    rng(iShape);
    dists = radius * rand(nVertices, 1);
    verts = dists .* [cos(theta) sin(theta)] + center;
    shape0 = BSplinePolygon2D(verts);

    % save table of vertex coordinates
    tabVertices = Table(verts, {'X', 'Y'});
    fileName = sprintf('vertices_%s.txt', shapeName);
    write(tabVertices, fullfile(paramsOutputDir, fileName));

    % save a table containing only the perimeter of the shape
    pth = perimeter(shape0);
    tabPerim = Table(pth, {'Perimeter'}, {shapeName});
    fileName = sprintf('perimeter_%s.txt', shapeName);
    write(tabPerim, fullfile(paramsOutputDir, fileName));

    % iterate over simulations
    for iSimul = 1:nSimuls
        fprintf('.');
        if mod(iSimul, 20) == 0
            fprintf(' %4d/%d\n', iSimul, nSimuls);
        end
        
        % generate random parameters
        shift = params(iSimul, 1:2);
        angle = deg2rad(params(iSimul, 3));
    
        % apply random displacement to shape
        shape = translate(rotate(shape0, angle, [50 50]), shift);

        % generate discrete image of the shape
        poly = asPolyline(shape, 1000);
        img = reshape(isPointInPolygon([x(:) y(:)], poly), [100 100]);
    
        % keep image
        stack(:,:,iSimul) = img * 255;
    end
    
    %% Post-processing

    % save the stack of images
    stackFileName = [shapeName '_stack.tif'];
    savestack(stack, fullfile(imagesOutputDir, stackFileName));
end
