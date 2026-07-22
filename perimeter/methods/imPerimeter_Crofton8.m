function p = imPerimeter_Crofton8(img, delta)
%imPerimeter_Crofton8 Compute Crofton perimeter using 4 directions.
%
%   P = imPerimeter_Crofton8(IMG)
%
%   Example
%     R = 40;
%     img = discreteDisk(1:100, 1:100, [50.12 50.23 R]);
%     perim = imPerimeter_boundaryPolygon(img)
%     pth = 2*pi*R;
%     error = 100 * (perim - pth) / pth
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

if nargin==1
    delta = [1 1];
end
d1 = delta(2);
d2 = delta(1);

thetas = [0, atan2(d2, 2*d1), atan2(d2, d1), atan2(2*d2, d1), pi/2];

dtheta = (thetas(3:end)-thetas(1:end-2))/2;
c = [thetas(2) dtheta (thetas(end)-thetas(end-1)) dtheta(end:-1:1)];

dim = size(img);
D1 = dim(1);
D2 = dim(2);

nv = sum(img(:));

% compute number of intersections with orthogonal lines
n1 = nv - sum(sum(img(1:D1-1, :) & img(2:D1, :)));
n2 = nv - sum(sum(img(:, 1:D2-1) & img(:, 2:D2)));

% compute number of intersections with diagonal lines
n3 = nv - sum(sum(img(1:D1-1, 1:D2-1) & img(2:D1,   2:D2))) ;
n4 = nv - sum(sum(img(1:D1-1, 2:D2  ) & img(2:D1, 1:D2-1))) ;

% compute number of intersections with 'chess-knight' direction lines
n5 = nv - sum(sum(img(1:D1-2, 1:D2-1) & img(3:D1, 2:D2)));
n6 = nv - sum(sum(img(1:D1-1, 1:D2-2) & img(2:D1, 3:D2)));
n7 = nv - sum(sum(img(2:D1, 1:D2-2) & img(1:D1-1, 3:D2)));
n8 = nv - sum(sum(img(3:D1, 1:D2-1) & img(1:D1-2, 2:D2)));

% compute weights associated to lines
vol = d1*d2;
l1 = vol/d1;
l2 = vol/d2;
d11 = hypot(d1, d2);
l3 = vol/d11;
l4 = vol/d11;
d12 = hypot(d1, 2*d2);
d21 = hypot(2*d1, d2);
l5 = vol/d12;
l6 = vol/d21;
l7 = vol/d21;
l8 = vol/d12;

neis = [n1 n2 n3 n4 n5 n6 n7 n8]';
lis = [l1 l2 l3 l4 l5 l6 l7 l8]';
cis = c'/pi;

p = pi*sum(neis.*lis.*cis);

