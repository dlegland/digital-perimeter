function createImages_starfish_40_25(varargin)
%CREATEIMAGES_STARFISH_40_25  One-line description here, please.
%
%   output = createImages_starfish_40_25(input)
%
%   Example
%   createImages_starfish_40_25
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

% shape size, and shape name
radius = 40;
radius2 = 25;
shapeName = sprintf('Starfish_%02d_%02d', radius, radius2);

% size of digitized 2D images
dims = [100 100];

% number of simulations
nSimuls = 1000;

% allocate memory for result image (and parameter table)
params = zeros(nSimuls, 3);
stack = zeros([dims nSimuls], 'uint8');


%% Main iteration

% iterate over simulations
for iSimul = 1:nSimuls
    % generate shape with random position
    center = rand(1,2) + 50;
    theta = rand * 180;
    params(iSimul,:) = [center theta];

    % generate discrete image
    shape = StarFish2D([center radius radius2 theta]);
    img = discretize(shape, 1:dims(2), 1:dims(1));
    stack(:,:,iSimul) = img * 255;
end


%% Post-processing

% save table of position + orientation
tabParams = Table(params, {'CenterX', 'CenterY', 'Theta'});
paramFileName = sprintf('params_%s.txt', shapeName);
write(tabParams, fullfile('params', paramFileName));

% save stack of 2D images
stackFileName = [shapeName '_stack.tif'];
savestack(stack, fullfile('images', stackFileName));
