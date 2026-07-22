%CHECKPERIMETER_DISKR50  One-line description here, please.
%
%   output = checkPerimeter_DiskR50(input)
%
%   Example
%   checkPerimeter_DiskR50
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-10-06,    using Matlab 9.14.0.2337262 (R2023a) Update 5
% Copyright 2023 INRAE.

%% Initialisations

Rab = [40 20];
pth = ellipsePerimeter(Rab);
shapeName = sprintf('Ellipse_A%02d_B%02d', Rab(1), Rab(2));

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

for iSimul = 1:nSimuls
    center = rand(1,2) + 50;
    theta = rand * 180;
    params(iSimul,:) = [center theta];

    % generate discrete image
    elli = [center Rab theta];
    img = discreteEllipse(dims, elli);

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