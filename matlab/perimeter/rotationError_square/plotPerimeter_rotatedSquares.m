%PLOTCURVESPERIMETERSQUARE_BYORIENT  One-line description here, please.
%
%   output = plotCurvesPerimeterSquare_byOrient(input)
%
%   Example
%   plotCurvesPerimeterSquare_byOrient
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-09-26,    using Matlab 9.14.0.2306882 (R2023a) Update 4
% Copyright 2023 INRAE.

% path to measures obtained with ImageJ
imageJPath = fullfile('..', '..', '..', 'imagej', 'tables');

% read data
tab = Table.read(fullfile(imageJPath, 'perimeter_squareS100_byOrient_error_summary.txt'));

% prepare graphics
figure; hold on; set(gca, 'fontsize', 16);

% plot curves of mean error
h0 = plot(tab('Angle'), zeros(size(tab('Angle'))), 'color', 'k');
h1 = plot(tab('Angle'), tab('ImageJ'), 'color', 'r', 'linewidth', 2);
h2 = plot(tab('Angle'), tab('Crofton2'), 'color', [0 .8 0], 'linewidth', 2);
h3 = plot(tab('Angle'), tab('Crofton4'), 'color', [0 0 .8], 'linewidth', 2);

% plot curves of +/- 2*STD
options = {'lineWidth', 0.5, 'linestyle', '-'};
ijMean = tab('ImageJ'); ijStd = tab('ImageJStd');
h1s = plot(tab('Angle'), ijMean - 2*ijStd, 'color', 'r', options{:});
plot(tab('Angle'), ijMean + 2*ijStd, 'color', 'r', options{:});
crofton2Mean = tab('Crofton2'); crofton2Std = tab('Crofton2Std');
h2s = plot(tab('Angle'), crofton2Mean - 2*crofton2Std, 'color', [0 .8 0], options{:});
plot(tab('Angle'), crofton2Mean + 2*crofton2Std, 'color', [0 .8 0], options{:});
crofton4Mean = tab('Crofton4'); crofton4Std = tab('Crofton4Std');
h3s = plot(tab('Angle'), crofton4Mean - 2*crofton4Std, 'color', [0 0 .8], options{:});
plot(tab('Angle'), crofton4Mean + 2*crofton4Std, 'color', [0 0 .8], options{:});

ylim([-25 15]);
xlim([0 180]);

legend([h1 h1s h2 h2s h3 h3s], ...
    {'ImageJ', '(\pm 2*std)', 'Crofton 2', '(\pm 2*std)', 'Crofton 4', '(\pm 2*std)'}, ...
    'Location', 'SouthEast');
xlabel('Orientation of the square (degrees)');
ylabel('Relative deviation (%)');
title('');
%title('Relative errPerimeter measure');

print(gcf, 'perimeterSquareS100_byOrient.png', '-dpng');


%% Figure 2
% Add curve obtained with Matlab 

tabM = Table.read('perimSquareL100_Matlab.txt');
perimM = tabM.Data;
orientM = str2double(tabM.ColNames');

% compute error
errorM = 100 * (perimM - 400) / 400;
errorMmean = mean(errorM);
errorMsd = std(errorM);

% add Matlab curve
hM = plot(orientM, errorMmean, 'color', [200 080 015]/255, 'linewidth', 2);
hMs = plot(orientM, errorMmean - 2*errorMsd, 'color', [200 080 015]/255, options{:});
plot(orientM, errorMmean + 2*errorMsd, 'color', [200 080 015]/255, options{:});

legend([h1 h1s h2 h2s h3 h3s hM hMs], ...
    {'ImageJ', '(\pm 2*std)', 'Crofton 2', '(\pm 2*std)', 'Crofton 4', '(\pm 2*std)', 'Matlab', '(\pm 2*std)'}, ...
    'Location', 'SouthEast');
xlabel('Orientation of the square (degrees)');
ylabel('Relative deviation (%)');
title('');
%title('Relative errPerimeter measure');

print(gcf, 'perimeterSquareS100_byOrient_withMatlab.png', '-dpng');
