%CALCPERIMETERROTATEDSQUARES  One-line description here, please.
%
%   output = calcPerimeterRotatedSquares(input)
%
%   Example
%   resolErrorDisk
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-01-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Definitions 


% rotation angles
angles = 1:.5:180;

Ns = 1000;

% features of the square (except rotation angle)
dims = [200 200];
center = dims/2 + [pi-3 exp(1)-2];
sideLength = 100;

% image de demo
square = [center sideLength 30];
img = discreteSquare(dims, square);
figure(1); clf;
imshow(img);


%% measure perimeters

% allocation memoire
perim2 = zeros(Ns, length(angles));
perim4 = zeros(Ns, length(angles));
perimM = zeros(Ns, length(angles));

% iterate over angles
for i = 1:length(angles)
    for s = 1:Ns
        % create a rotated square with random position
        center = dims/2 + rand(1, 2);
        square = [center sideLength angles(i)];
        
        % compute binary image of square
        img = discreteSquare(dims, square);
        
        % measure the perimeter using several methods
        % measure using Crofton method (within matImage library)
        perim2(s, i) = imPerimeter(img, 2);
        perim4(s, i) = imPerimeter(img, 4);
        
        % measure perimeter using Matlab Image Processing toolbox 
        % that uses corner-count method
        props = regionprops(img>0, 'Perimeter');
        perimM(s, i) = props.Perimeter;
    end
end


%% Create and save data tables
colNames = cellstr(num2str(angles', '%7.5f'))';

tab2 = Table.create(perim2, 'colNames', colNames);
write(tab2, 'perimSquareL100_Crofton2.txt');

tab4 = Table.create(perim4, 'colNames', colNames);
write(tab4, 'perimSquareL100_Crofton4.txt');

tabM = Table.create(perimM, 'colNames', colNames);
write(tabM, 'perimSquareL100_Matlab.txt');
