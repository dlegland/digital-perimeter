%COMPUTE_SUMMARY_IMAGEJ  One-line description here, please.
%
%   output = compute_summary_imagej(input)
%
%   Example
%   compute_summary_imagej
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-07-30,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE.


radius = 50;
nVertices = 8;


nShapes = 50;
nSimuls = 1000;


tabGlobal = Table.create(zeros(nShapes, 7), ...
    'ColNames', {'Ref', 'ImageJ-mean', 'ImageJ-std', 'Crofton2-mean', 'Crofton2-std', 'Crofton4-mean', 'Crofton4-std'});


% iShape = 1;
for iShape = 1:nShapes

    inputDir = sprintf('polar%d_%02d', nVertices, iShape-1);
    if ~exist(inputDir, 'dir')
        mkdir(inputDir);
    end
    
    % retrieve table of vertex coordinates
    shapeName = sprintf('BSplinePolar%d_R50_%d', nVertices, iShape-1);
    tabVertices = Table.read(fullfile(inputDir, sprintf('vertices_%s.txt', shapeName)));
    
    shape0 = BSplinePolygon2D(tabVertices.Data);
    pth = perimeter(shape0);
    
    disp(pth)
    
    % read table containing imagej measurements
    ijDir = fullfile('..', '..', '..', '..', 'imagej', 'tables', 'polarSplines', 'polar8_R50');
    fileName = sprintf('BSplinePolar%d_R%02d_%02d.txt', nVertices, radius, iShape-1);
    tab = Table.read(fullfile(ijDir, fileName));
    
    tabErr = 100 * (tab(:, 2:4) - pth) / pth;
    tabErr.ColNames = tab.ColNames(2:4);
    tabSummary = [mean(tabErr) ; std(tabErr)];
    
    tabGlobal.Data(iShape,:) = [pth tabSummary.Data(:)'];
end

write(tabGlobal, 'imagej-summary.txt', '%7.3f  %7.3f %7.3f  %7.3f %7.3f  %7.3f %7.3f\n');
