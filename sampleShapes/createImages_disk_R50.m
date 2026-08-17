%CREATEIMAGES_DISK_R50  One-line description here, please.
%
%   output = createImages_disk_R50(input)
%
%   Example
%   createImages_disk_R50
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-08-17,    using Matlab 26.1.0.3251617 (R2026a) Update 2
% Copyright 2026 INRAE.

%% Initializations

% disk radius, and shape name
R = 50;
shapeName = sprintf('Disk_R%02d', R);

% size of digitized 2D images
dims = [120 120];

% number of simulations
nSimuls = 1000;

% allocate memory for result image (and parameter table)
params = zeros(nSimuls, 2);
stack = zeros([dims nSimuls], 'uint8');


%% Main iteration

% iterate over simulations
for iSimul = 1:nSimuls
    % generate shape with random position
    center = rand(1,2) + 60;
    params(iSimul,:) = center;

    % generate discrete image
    disk = [center R];
    img = discreteDisk(dims, disk) * 255;
    stack(:,:,iSimul) = img;
end


%% Post-processing

% save table of positions
tabParams = Table(params, {'CenterX', 'CenterY'});
paramFileName = sprintf('params_%s.txt', shapeName);
write(tabParams, fullfile('params', paramFileName));

% save stack of 2D images
stackFileName = [shapeName '_stack.tif'];
savestack(stack, fullfile('images', stackFileName));
