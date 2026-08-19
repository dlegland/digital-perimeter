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

% create polar basis
theta = linspace(0, 2*pi, nVertices+1)';
theta(end) = [];

% size of digitized image
dims = [100 100];

% discretization parameters
lx = 1:100;
ly = 1:100;
[x, y] = meshgrid(lx, ly);


nShapes = 50;

% allocate memory for storing simulation results
nSimuls = 1000;
params = zeros(nSimuls, 3);
resBndPoly  = zeros(nSimuls, 1);
resCrofton2 = zeros(nSimuls, 1);
resCrofton4 = zeros(nSimuls, 1);
resMatlab   = zeros(nSimuls, 1);

% allocate memory for an image containing all discretizations
stack = zeros([dims nSimuls], 'uint8');


%% Main iteration: over shapes

for iShape = 1:nShapes
    fprintf('shape %d/%d\n', iShape, nShapes);

    shapeName = sprintf('BSplinePolar%d_R50_%d', nVertices, iShape-1);

    outputDir = sprintf('polar%d_%02d', nVertices, iShape-1);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % create a sample of the shape
    rng(iShape);
    dists = radius * rand(nVertices, 1);
    verts = dists .* [cos(theta) sin(theta)] + center;

    % save table of vertex coordinates
    tabVertices = Table(verts, {'X', 'Y'});
    write(tabVertices, fullfile(outputDir, sprintf('vertices_%s.txt', shapeName)));
  
    % compute reference perimeter
    shape0 = BSplinePolygon2D(verts);
    pth = perimeter(shape0);


    % iterate over simulations
    for iSimul = 1:nSimuls
        fprintf('.');
        if mod(iSimul, 20) == 0
            fprintf(' %4d/%d\n', iSimul, nSimuls);
        end
        
        % generate random parameters
        shift = rand(1,2);
        rotAngle = rand * 180;
        params(iSimul,:) = [center rotAngle];
    
        % generate discrete image of the shape
        shape = translate(rotate(shape0, deg2rad(rotAngle), [50 50]), shift);
        poly = asPolyline(shape, 1000);
        img = reshape(isPointInPolygon([x(:) y(:)], poly), [100 100]);
    
        % keep image
        stack(:,:,iSimul) = img * 255;
    
        % measure perimeter using various methods
        polys = imBoundaryContours(img);
        resBndPoly(iSimul) = sum(cellfun(@polygonLength, polys));
        resCrofton2(iSimul) = imPerimeter(img, 2);
        resCrofton4(iSimul) = imPerimeter(img, 4);
        props = regionprops(img, 'Perimeter');
        resMatlab(iSimul) = props.Perimeter;
    end
    
    %% Post-processing
    
    % save table of position + orientation
    tabParams = Table(params, {'ShiftX', 'ShiftY', 'Rotation'});
    write(tabParams, fullfile(outputDir, sprintf('params_%s.txt', shapeName)));
    
    % save table of perimeter measurements (including reference perimeter)
    colNames = {'BoundaryC8', 'Crofton2', 'Crofton4', 'Matlab', 'MatlabPi'};
    perims = [resBndPoly resCrofton2 resCrofton4 resMatlab (resMatlab+pi)];
    tabPerims = Table([pth(ones(nSimuls,1)), perims], [{'Reference'} colNames]);
    write(tabPerims, fullfile(outputDir, sprintf('perimeter_%s.txt', shapeName)));
    
    % compute relative errors
    errors = 100 * (perims - pth) / pth;
    tabErrors = Table(errors, colNames);
    write(tabErrors, fullfile(outputDir, sprintf('perimeter_%s_errors.txt', shapeName)));
    
    % summary of relative errors
    tabStats = [mean(tabPerims(:,2:end))' mean(tabErrors)'  std(tabErrors)'];
    write(tabStats, fullfile(outputDir, sprintf('perimeter_%s_summary.txt', shapeName)));
    disp(tabStats)
    
    savestack(stack, fullfile(outputDir, sprintf('%s_stack.tif', shapeName)));
end
