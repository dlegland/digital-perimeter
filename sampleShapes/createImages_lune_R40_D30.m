function createImages_lune_R40_D30(varargin)
%CREATEIMAGES_LUNE_R40_D30  One-line description here, please.
%
%   output = createImages_lune_R40_D30(input)
%
%   Example
%   createImages_lune_R40_D30
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

% lune size, and shape name
R = 40;
d = 30;
shapeName = sprintf('Lune_R%02d_D%02d', R, d);

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
    lune = [center R d theta];
    img = discreteLune(dims, lune) * 255;
    stack(:,:,iSimul) = img;
end


%% Post-processing

% save table of position + orientation
tabParams = Table(params, {'CenterX', 'CenterY', 'Theta'});
paramFileName = sprintf('params_%s.txt', shapeName);
write(tabParams, fullfile('params', paramFileName));

% save stack of 2D images
stackFileName = [shapeName '_stack.tif'];
savestack(stack, fullfile('images', stackFileName));
