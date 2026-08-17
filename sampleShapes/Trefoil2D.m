classdef (InferiorClasses = {?matlab.graphics.axis.Axes}) Trefoil2D
% One-line description here, please.
%
%   Class Trefoil2D
%
%   Example
%   shape = Trefoil2D([50 50 40 25 10]);
%   poly = asPolyline(shape, 300);
%   img = discretize(shape, 1:100, 1:100);
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2026-04-01,    using Matlab 25.1.0.2973910 (R2025a) Update 1
% Copyright 2026 INRAE - BIA-BIBS.


%% Properties
properties
    % The x-coordinate of the center.
    CenterX = 0;
    % The y-coordinate of the center.
    CenterY = 0;
    % the outer radius.
    Rout = 10;
    % the inner radius.
    Rin = 5;
    % the orientation of the first point of the curve, in degrees.
    Orientation = 0;
end % end properties


%% Constructor
methods
    function obj = Trefoil2D(varargin)
        % Constructor for Trefoil2D class.

        switch nargin
            case 0
                % nothing to do
            case 1
                var1 = varargin{1};
                if size(var1, 2) ~= 5
                    error('Creating a Trefoil2D requires an array with five columns, not %d', size(var1, 2));
                end
                obj.CenterX = var1(1);
                obj.CenterY = var1(2);
                obj.Rout    = var1(3);
                obj.Rin     = var1(4);
                obj.Orientation = var1(5);
        end
    end

end % end constructors


%% Methods
methods
    function img = discretize(obj, lx, ly)
        % Compute a digital image representing this shape.
        % img = discretize(obj, lx, ly)
        % LX and LY are row vectors containing coordinates of image xdata
        % and ydata, respectively.
        [x, y] = meshgrid(lx, ly);
        img = reshape(isInside(obj, [x(:) y(:)]), size(x));
    end

    function res = isInside(obj, pts)
        % Check whether the specified point(s) is within the shape.
        % res = isInside(obj, pts)
        % pts is expected to be a N-by-2 array of numerical values.

        xc = obj.CenterX;
        yc = obj.CenterY;
        rOut = obj.Rout;
        rIn = obj.Rin;
        theta0 = deg2rad(obj.Orientation);
        
        % transforms points according to shape position
        coordsT = pts - [xc yc];

        % convert to polar coordinates
        [th, rho] = cart2pol(coordsT(:,1), coordsT(:,2));

        % compute theoretical polar distance
        rhoTh = (rOut+rIn)/2 + (rOut-rIn)/2 * cos(3 * (th - theta0));

        % create image
        res = false(size(rho));
        res(rho < rhoTh) = 1;
    end

end % end methods


%% Methods related to smooth curve
methods
end


%% Methods related to curve
methods
    function poly = asPolyline(obj, varargin)
        % Convert this shape into a (closed) polyline.
        %
        % POLY = asPolyline(OBJ);
        % POLY = asPolyline(OBJ, NPTS);
        % Returns the result as an instance of LinearRing2D. Can specify
        % the number of vertices of the polyline as second argument.
        %
        % See Also
        %   Polyline2D, perimeter
        
        % determines number of points
        N = 120;
        if ~isempty(varargin)
            N = varargin{1};
        end
        
        % create parameterization of angular coordinates
        t = linspace(0, 2*pi, N+1)';
        t(end) = [];
        
        [x, y] = pointCoords(obj, t);
        poly = [x y];
    end
    
    function pts = point(obj, pos)
        % Find a point on this shape from its position.
        %
        %   P = point(ELLI, POS);
        %
        
        [x, y] = pointCoords(obj, pos);
        pts = [x, y];
    end

    function [x, y] = pointCoords(obj, t)
        % Find coordinates of a point on ellipse from its position.
        %
        %   [X, Y] = pointCoords(SHAPE, POS);
        %
        
        % get shape parameters
        % equation is given in polar form, then the parametric coordinate
        % corresponds to the angle.
        xc = obj.CenterX;
        yc = obj.CenterY;
        rOut = obj.Rout;
        rIn = obj.Rin;
        theta0 = deg2rad(obj.Orientation);
        
        % compute distance to center
        rho = (rOut+rIn)/2 + (rOut-rIn)/2 .* cos(3 * (t - theta0));

        % position of points
        x = xc + rho .* cos(t);
        y = yc + rho .* sin(t);
    end
end


methods
    function box = bounds(obj)
        % Return the bounds of this shape.
        %
        % See Also
        %   Bounds2D, center
        
        extX = [obj.CenterX - obj.Rout obj.CenterX + obj.Rout];
        extY = [obj.CenterY - obj.Rout obj.CenterY + obj.Rout];
        box = [extX extY];
    end
end % end methods


%% Draw methods
methods
    function h = draw(varargin)
        %DRAW Draw the current shape, eventually specifying the style.
        
        % parse arguments using protected method implemented in Drawable
        [ax, obj, style, varargin] = parseDrawInputArguments(varargin{:});
        holdState = ishold(ax);
        hold(ax, 'on');

        % extract data
        [x, y] = pointCoords(obj, linspace(0, 2*pi, 121));
        
        % draw outline
        if isempty(varargin)
            varargin = {'Color', 'b', 'LineStyle', '-'};
        end
        h1 = plot(ax, x, y, varargin{:});
        if ~isempty(style)
            apply(style, h1);
        end
        
        if holdState
            hold(ax, 'on');
        else
            hold(ax, 'off');
        end
        
        if nargout > 0
            h = h1;
        end
    end
end


%% Serialization methods
methods
    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization.
        str = struct('Type', 'Trefoil2D', ...
            'CenterX', obj.CenterX, ...
            'CenterY', obj.CenterY, ...
            'OuterRadius', obj.Rout, ...
            'InnerRadius', obj.Rin, ...
            'Orientation', obj.Orientation);
    end
end

methods (Static)
    function shape = fromStruct(str)
        % Create a new instance from a structure.
        shape = Trefoil2D([str.CenterX str.CenterY str.OuterRadius str.InnerRadius str.Orientation]);
    end
end

%% Utility methods
methods (Access = protected)
    function [ax, obj, style, varargin] = parseDrawInputArguments(varargin)
        % Return the different elements necessary to draw the object.
        %
        % Usage:
        %   [ax, obj, style, varargin] = parseDrawInputArguments(varargin{:});
        %
        % Returns the following:
        % - 'ax' is the handle of the axis to draw in, that can be used as
        %     first input for plot functions. If not specified, the current
        %     axis is returned.
        % - 'obj' is the instance of the object, that should be a subclass
        %     of Drawable
        % - 'style' is an optional 'Style', that can be used to update the
        %     drawing style of the graphical object.
        % - 'varargin' are the remaining input arguments.
        %
        
        % identify the variable corresponding to class instance
        [obj, varargin] = parseDrawable(varargin{:});
        
        % extract handle of axis to draw on
        [ax, varargin] = parseAxis(varargin{:});
        
        [style, varargin] = parseStyle(varargin{:});
    end
end % end methods

end % end classdef


function [obj, varargin] = parseDrawable(varargin)
    % parse the instance of Drawable.
    ind = cellfun(@(x) isa(x, 'Trefoil2D'), varargin);
    obj = varargin{ind};
    varargin(ind) = [];
end

function [ax, varargin] = parseAxis(varargin)
    % parse handle of axis to draw on.
    if ~isempty(varargin) && isscalar(varargin{1}) && ishghandle(varargin{1}) && strcmpi(get(varargin{1}, 'type'), 'axes')
        ax = varargin{1};
        varargin(1) = [];
    else
        ax = gca;
    end
end

function [style, varargin] = parseStyle(varargin)
    % parse optional style info
    style = [];
    ind = cellfun(@(x) isa(x, 'mgt.Style'), varargin);
    if any(ind)
        style = varargin{ind};
        varargin(ind) = [];
    end
end

