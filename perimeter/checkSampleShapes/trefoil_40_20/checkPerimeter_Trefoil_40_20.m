%CHECKPERIMETER_TREFOIL_40_25  Compare perimeter measurements on a lune.
%
%   output = checkPerimeter_LuneR40D30(input)
%
%   Example
%   checkPerimeter_LuneR40D30
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-06-04,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.


%% Initialisations

% shape size
radius = 40;
radius2 = 20;
shapeName = sprintf('Trefoil_%02d_%02d', radius, radius2);

% initialize random number generator for reproducibility
rng(42);

% compute theoretical perimeter from equivalent polygon
refShape = Trefoil2D([50 50 radius radius2 0]);
pth = polygonLength(asPolyline(refShape, 1000));

% size of digitized image
dims = [100 100];

% allocate memory for storing simulation results
nSimuls = 1000;
params = zeros(nSimuls, 3);
resBndPoly  = zeros(nSimuls, 1);
resCrofton2 = zeros(nSimuls, 1);
resCrofton4 = zeros(nSimuls, 1);
resMatlab   = zeros(nSimuls, 1);


%% Main iteration

% iterate over simulations
for iSimul = 1:nSimuls
    % generate random parameters
    center = rand(1,2) + 50;
    theta = rand * 180;
    params(iSimul,:) = [center theta];

    % generate discrete image of the shape
    shape = Trefoil2D([center radius radius2 theta]);
    img = discretize(shape, 1:100, 1:100);

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
tabParams = Table(params, {'CenterX', 'CenterY', 'Theta'});
write(tabParams, sprintf('params_%s.txt', shapeName));

% save table of perimeter measurements (including reference perimeter)
colNames = {'BoundaryC8', 'Crofton2', 'Crofton4', 'Matlab', 'MatlabPi'};
perims = [resBndPoly resCrofton2 resCrofton4 resMatlab (resMatlab+pi)];
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