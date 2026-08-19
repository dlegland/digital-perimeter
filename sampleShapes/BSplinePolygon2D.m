classdef (InferiorClasses = {?matlab.graphics.axis.Axes}) BSplinePolygon2D
% A smooth closed curve obtained by interpolating polygon vertices.
%
%   Class BSplinePolygon2D
%
%   Example
%     verts = [10 10; 30 10; 40 20;30 40;25 20; 10 30];
%     curve = BSplinePolygon2D(verts);
%     figure; hold on; axis equal; axis([0 50 0 50]);
%     drawPolygon(verts, 'b-')
%     draw(curve, 'lineWidth', 2, 'color', 'm');
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
    % The vertex coordinates, as a N-by-2 array of numeric values.
    Coords;

end % end properties


%% Constructor
methods
    function obj = BSplinePolygon2D(varargin)
        % Constructor for BSplinePolygon2D class.

        if nargin == 0
            obj.Coords = zeros(0,2);
            return;
        end

        obj.Coords = varargin{1};
    end
end % end constructors


%% Methods specific to BSplinePolygon2D
methods
    function len = perimeter(obj, varargin)
        % Computes perimeter length of this curve.

        % tolerance
        tol = 1e-6;
        if ~isempty(varargin)
            tol = varargin{1};
        end

        nv = size(obj.Coords, 1);
        len = integral(@(t) ds(obj, t), 0, nv, 'AbsTol', tol);
    end

    function ds = ds(obj, t)
        [xd, yd] = derivatives(obj, t);
        ds = hypot(xd, yd);
    end

    function kappa = curvature(obj, pos)
        % Compute curvature at specified position(s).

        [xd, yd, xs, ys] = derivatives(obj, pos);
        kappa = (xd .* ys - xs .* yd) ./ (xd.^2 + yd.^2) .^ 1.5;
    end
end % end methods


%% Methods related to smooth curve
methods
    function [xd, yd, xs, ys] = derivatives(obj, pos)
        % Derivatives of each coordinate wrt parameterization.
        %
        %   [XD, YD] = derivatives(CURVE, T);
        %   Returns the derivatives of the two parametric functions x(t)
        %   and y(t) with respect to the parameter t.
        %
        %   [XD, YD, XS, YS] = derivatives(CURVE, T);
        %   Also returns the second derivatives.
        %
        %   See Also
        %     curvature

        beta3_0d = @(u) -(1 - u).^2 / 2;
        beta3_1d = @(u) 3*u.^2 / 2 - 2*u;
        beta3_2d = @(u) (-3*u.^2 + 2*u + 1) / 2;
        beta3_3d = @(u) u.^2 / 2;
        
        ind = floor(pos);
        t = pos - ind;
        dim = size(t);

        nv = size(obj.Coords, 1);
        ind0 = mod(ind + nv - 1, nv) + 1;
        ind1 = mod(ind + nv, nv) + 1;
        ind2 = mod(ind + nv + 1, nv) + 1;
        ind3 = mod(ind + nv + 2, nv) + 1;

        xd = reshape(obj.Coords(ind0,1), dim) .* beta3_0d(t);
        yd = reshape(obj.Coords(ind0,2), dim) .* beta3_0d(t);
        xd = xd + reshape(obj.Coords(ind1,1), dim) .* beta3_1d(t);
        yd = yd + reshape(obj.Coords(ind1,2), dim) .* beta3_1d(t);
        xd = xd + reshape(obj.Coords(ind2,1), dim) .* beta3_2d(t);
        yd = yd + reshape(obj.Coords(ind2,2), dim) .* beta3_2d(t);
        xd = xd + reshape(obj.Coords(ind3,1), dim) .* beta3_3d(t);
        yd = yd + reshape(obj.Coords(ind3,2), dim) .* beta3_3d(t);

        if nargout > 2
            beta3_0s = @(u) 1 - u;
            beta3_1s = @(u) 3 * u - 2;
            beta3_2s = @(u) 1 - 3 * u;
            beta3_3s = @(u) u;
            xs = reshape(obj.Coords(ind0,1), dim) .* beta3_0s(t);
            ys = reshape(obj.Coords(ind0,2), dim) .* beta3_0s(t);
            xs = xs + reshape(obj.Coords(ind1,1), dim) .* beta3_1s(t);
            ys = ys + reshape(obj.Coords(ind1,2), dim) .* beta3_1s(t);
            xs = xs + reshape(obj.Coords(ind2,1), dim) .* beta3_2s(t);
            ys = ys + reshape(obj.Coords(ind2,2), dim) .* beta3_2s(t);
            xs = xs + reshape(obj.Coords(ind3,1), dim) .* beta3_3s(t);
            ys = ys + reshape(obj.Coords(ind3,2), dim) .* beta3_3s(t);
        end
    end
end


%% Methods related to curve
methods
    function poly = asPolyline(obj, varargin)
        % Convert this curve into a (closed) polyline.
        %
        % POLY = asPolyline(OBJ);
        % POLY = asPolyline(OBJ, NV);
        % Returns the result as a numeric array. Can specify
        % the number of vertices of the polygon as second argument.
        %
        
        % determines number of points per segment
        nv = size(obj.Coords, 1);
        N = 10;
        if ~isempty(varargin)
            N = varargin{1};
        end
        
        % create time basis
        t = linspace(0, nv, nv*N + 1)';
        t(end) = [];
        
        [x, y] = pointCoords(obj, t);
        poly = [x(:) y(:)];
    end

    function pts = point(obj, pos)
        % Find a point on this curve from its position.
        %
        %   P = point(ELLI, POS);
        %
        
        [x, y] = pointCoords(obj, pos);
        pts = [x(:) y(:)];
    end

    function [x, y] = pointCoords(obj, pos)
        % Find coordinates of point on curve from its position.
        %
        %   [X, Y] = pointCoords(CURV, POS);
        %   POS is given between 0 and NV, where NV is the number of
        %   vertices specifying this BSpline polygon. Note that the
        %   coordinates of the position 0 and NV are the same, as this is a
        %   closed curve.
        %
        
        beta3_0 = @(u) (1 - u).^3 / 6;
        beta3_1 = @(u) (3*u.^3 - 6*u.^2 + 4) / 6;
        beta3_2 = @(u) (-3*u.^3 + 3*u.^2 +3*u + 1) / 6;
        beta3_3 = @(u) u.^3 / 6;

        nv = size(obj.Coords, 1);

        ind = floor(pos);
        t = pos - ind;
        dim = size(t);

        ind0 = mod(ind + nv - 1, nv) + 1;
        ind1 = mod(ind + nv, nv) + 1;
        ind2 = mod(ind + nv + 1, nv) + 1;
        ind3 = mod(ind + nv + 2, nv) + 1;

        x = reshape(obj.Coords(ind0,1), dim) .* beta3_0(t);
        y = reshape(obj.Coords(ind0,2), dim) .* beta3_0(t);
        x = x + reshape(obj.Coords(ind1,1), dim) .* beta3_1(t);
        y = y + reshape(obj.Coords(ind1,2), dim) .* beta3_1(t);
        x = x + reshape(obj.Coords(ind2,1), dim) .* beta3_2(t);
        y = y + reshape(obj.Coords(ind2,2), dim) .* beta3_2(t);
        x = x + reshape(obj.Coords(ind3,1), dim) .* beta3_3(t);
        y = y + reshape(obj.Coords(ind3,2), dim) .* beta3_3(t);
    end
end


%% Methods implementing the Geometry2D interface
methods
    function res = transform(obj, transfo)
        % Apply a geometric transform to this curve.
        %

        coords = transformPoint(obj.Coords, transfo);
        res = BSplinePolygon2D(coords);
    end
    
    function res = scale(obj, factor)
        % Return a scaled version of this curve.
        res = BSplinePolygon2D(obj.Coords * factor);
    end
    
    function res = translate(obj, shift)
        % Return a translated version of this curve.
        res = BSplinePolygon2D(obj.Coords + shift);
    end
    
    function res = rotate(obj, angle, varargin)
        % Return a rotated version of this curve.
        transfo = createRotation(varargin{:}, angle);
        coords2 = transformPoint(obj.Coords, transfo);
        res = BSplinePolygon2D(coords2);
    end
end % end methods


%% Methods for vertex management
methods
    function verts = vertices(obj)
        % Return vertices of this shape as a numeric array.
        verts = obj.Coords;
    end
    
    function nv = vertexCount(obj)
        % Get the number of vertices in this polyline.
        nv = size(obj.Coords, 1);
    end
end


%% Draw methods
methods
    function h = draw(varargin)
        % DRAW Draw the curve.
        
        % parse arguments using protected method implemented in Drawable
        [ax, obj, varargin] = parseDrawInputArguments(varargin{:});
        
        % default drawing argument
        if isempty(varargin)
            varargin = {'b-'};
        end
        
        % allocate memory for handles
        n = numel(obj);
        hl(n) = matlab.graphics.chart.primitive.Line;
        hl = reshape(hl, size(obj));

        % iterate over ellipses
        for i = 1:numel(obj)
            % compute position of several points along the curve
            nv = size(obj(i).Coords, 1);
            N = 10;
            t = linspace(0, nv, nv*N + 1)';
            t(end) = [];

            % coordinates of points along current bezier polygon
            [x, y] = pointCoords(obj(i), t);
            
            % draw the curve
            hl(i) = plot(ax, x([1:end 1]), y([1:end 1]), varargin{:});
        end
        
        if nargout > 0
            h = hl;
        end
    end

    function h = drawVertices(varargin)
        % Draw vertices of this geometry, with optional drawing options.
        
        % parse arguments using protected method implemented in Geometry
        [ax, obj, varargin] = parseDrawInputArguments(varargin{:});
        holdState = ishold(ax);
        hold(ax, 'on');
        
        % default options
        if isempty(varargin)
            varargin = {'Marker', 's', 'Color', 'k', 'LineStyle', 'none'};
        end
        
        % extract data
        coords = vertexCoordinates(obj);
        xdata = coords(:,1);
        ydata = coords(:,2);
        
        hh = plot(ax, xdata, ydata, varargin{:});

        
        if holdState
            hold(ax, 'on');
        else
            hold(ax, 'off');
        end
        
        if nargout > 0
            h = hh;
        end
    end

end


%% Serialization methods
methods
    function write(obj, fileName, varargin)
        %WRITE Write geometry into a JSON file.
        % 
        % Requires implementation of the "toStruct" method.
        
        if exist('savejson', 'file') == 0
            error('Requires the ''jsonlab'' library');
        end
        savejson('', toStruct(obj), 'FileName', fileName, varargin{:});
    end

    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization.
        str = struct(...
            'Type', 'BSplinePolygon2D', ...
            'Coordinates', obj.Coords);
    end
end

methods (Static)
    function geom = read(fileName)
        %READ Read a geometry from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the ''jsonlab'' library');
        end
        geom = BSplinePolygon2D.fromStruct(loadjson(fileName));
    end

    function poly = fromStruct(str)
        % Create a new instance from a structure.
        if isfield(str, 'Coordinates')
            poly = BSplinePolygon2D(str.Coordinates);
        elseif isfield(str, 'coordinates')
            poly = BSplinePolygon2D(str.coordinates);
        else
            error('Field <Coordinates> of BSplinePolygon2D is not defined');
        end

    end
end


%% Utility methods

methods (Access = protected)
    function [ax, obj, varargin] = parseDrawInputArguments(varargin)
        % Return the different elements necessary to draw the object.
        %
        % Usage:
        %   [ax, obj, varargin] = parseDrawInputArguments(varargin{:});
        %
        % Returns the following:
        % - 'ax' is the handle of the axis to draw in, that can be used as
        %     first input for plot functions. If not specified, the current
        %     axis is returned.
        % - 'obj' is the instance of the BSplinePolygon2D object
        % - 'varargin' are the remaining input arguments.
        %
        
        % parse handle of axis to draw on.
        if ~isempty(varargin) && isscalar(varargin{1}) && ishghandle(varargin{1}) && strcmpi(get(varargin{1}, 'type'), 'axes')
            ax = varargin{1};
            varargin(1) = [];
        else
            ax = gca;
        end

        obj = varargin{1};
        varargin(1) = [];
    end
end

end % end classdef

