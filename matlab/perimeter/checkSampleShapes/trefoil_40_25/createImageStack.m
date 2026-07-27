%CREATEIMAGESTACK  One-line description here, please.
%
%   output = createImageStack(input)
%
%   Example
%   createImageStack
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2026-06-04,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE.

% shape size
radius = 40;
radius2 = 25;

% size of digitized image
dims = [100 100];

% retrieve positions and orientations
tab = Table.read('params_Trefoil_40_25.txt');

% allocte memory for result image
nSimuls = size(tab, 1);
img = zeros([dims nSimuls], 'uint8');

% iterate over simulations
for iSimul = 1:nSimuls
    % retrieve shape parameters
    params = tab.Data(iSimul, :);
    center = params(1:2);
    theta = params(3);

    % generate discrete image of the shape
    shape = Trefoil2D([center radius radius2 theta]);
    img(:,:,iSimul) = discretize(shape, 1:100, 1:100) * 255;
end

% save stack of 2D images
savestack(img, 'trefoil_40_25_stack.tif');
