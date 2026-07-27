%PLOTPERIMETERDISK_BYRADIUS  One-line description here, please.
%
%   Usage:
%     plotPerimeterDisk_byRadius
%
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
tab = Table.read(fullfile(imageJPath, 'perimeter_disk_R01to70_error_summary.txt'));
radius = tab('Radius').Data;
tab2 = Table.read('perimDisk_R01To50_matlab_summary.txt');
radius2 = str2double(tab2.RowNames);


%% Figure 1

% prepare graphics
figure; hold on; set(gca, 'fontsize', 16);

% plot curves of mean error
h1 = plot(radius, tab('ImageJ').Data, 'color', [101 164 227]/255, 'linewidth', 2);
h2 = plot(radius, tab('Crofton2').Data, 'color', [0 .8 0], 'linewidth', 2);
h3 = plot(radius, tab('Crofton4').Data, 'color', [0 0 .8], 'linewidth', 2);

% plot curves of +/- 2*STD
options = {'lineWidth', 0.5, 'linestyle', '-'};
ijMean = tab('ImageJ').Data; ijStd = tab('ImageJStd').Data;
h1s = plot(tab('Radius'), ijMean - 2*ijStd, 'color', [101 164 227]/255, options{:});
plot(tab('Radius'), ijMean + 2*ijStd, 'color', [101 164 227]/255, options{:});
crofton2Mean = tab('Crofton2'); crofton2Std = tab('Crofton2Std');
h2s = plot(tab('Radius'), crofton2Mean - 2*crofton2Std, 'color', [0 .8 0], options{:});
plot(tab('Radius'), crofton2Mean + 2*crofton2Std, 'color', [0 .8 0], options{:});
crofton4Mean = tab('Crofton4'); crofton4Std = tab('Crofton4Std');
h3s = plot(tab('Radius'), crofton4Mean - 2*crofton4Std, 'color', [0 0 .8], options{:});
plot(tab('Radius'), crofton4Mean + 2*crofton4Std, 'color', [0 0 .8], options{:});

ylim([-25 15]);
xlim([1 50]);
set(gca, 'XScale', 'linear');

legend([h1 h1s h2 h2s h3 h3s], ...
    {'ImageJ', '(\pm 2*std)', 'Crofton 2', '(\pm 2*std)', 'Crofton 4', '(\pm 2*std)'}, ...
    'Location', 'SouthEast');
xlabel('Radius of the disk (pixels)');
ylabel('Relative deviation (%)');
title('');

print(gcf, 'perimeterDisk_byRadius.png', '-dpng');


%% Figure 2
% Add curve obtained with Matlab 

mlMean = tab2('errorMean'); mlStd = tab2('errorStd');
h4 = plot(radius2, mlMean, 'color', [200 080 015]/255, 'linewidth', 2);
options = {'lineWidth', 0.5, 'linestyle', '-'};
h4s = plot(radius2, mlMean - 2*mlStd, 'color', [200 080 015]/255, options{:});
plot(radius2, mlMean + 2*mlStd, 'color', [200 080 015]/255, options{:});

% ylim([-25 20]);
% xlim([1 24]);

legend([h1 h1s h2 h2s h3 h3s h4 h4s], ...
    {'ImageJ', '(\pm 2*std)', 'Crofton 2', '(\pm 2*std)', 'Crofton 4', '(\pm 2*std)', 'Matlab', '(\pm 2*std)'}, ...
    'Location', 'SouthEast');

title('');

print(gcf, 'perimeterDisk_byRadius_withMatlab.png', '-dpng');
