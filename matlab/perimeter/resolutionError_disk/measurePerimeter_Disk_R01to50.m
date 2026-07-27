%CALCPERIMDISK_R01TO50  One-line description here, please.
%
%   usage:
%   measurePerimeter_Disk_R01to50
%
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-10-02,    using Matlab 9.14.0.2337262 (R2023a) Update 5
% Copyright 2023 INRAE.

% generate radius list
radiusList = 1:0.02:50;
nRadius = length(radiusList);

% number of repetitions for evaluation of precision
nSimuls = 1000;

% create empty array for result
tab = Table.create(zeros([nRadius nSimuls]));

% iterate over disk sizes
for iRadius = 1:nRadius
    radius = radiusList(iRadius);
    fprintf('iter %d/%d, r=%f\n', iRadius, nRadius, radius);

    % for each radius, simulate several disks
    for iSimul = 1:nSimuls
        siz = round(2 * radius + 10);
        dims = [siz siz];

        % generate random disk
        center = rand(1,2) + dims * 0.5;
        disk = [center radius];

        % generate binary image of disk
        img = discreteDisk(dims, disk);

        % measure perimeter
        props = regionprops(img, 'Perimeter');
        perim = props.Perimeter;

        tab(iRadius, iSimul) = perim;
    end
end


write(tab, 'perimDisk_R01To50_matlab.txt');

% compute summary statistics by radius
pth = 2*pi*radiusList';
perimMean = mean(tab.Data, 2);
perimStd = std(tab.Data, 0, 2);


error = 100 * (tab.Data - pth) ./ pth;
errorMean = mean(error, 2);
errorStd = std(error, 0, 2);

stats = [errorMean errorStd];

colNames = {'errorMean', 'errorStd'};
rowNames = strtrim(cellstr(num2str(radiusList')));
tab2 = Table.create(stats, colNames, rowNames);
write(tab2, 'perimDisk_R01To50_matlab_summary.txt');

