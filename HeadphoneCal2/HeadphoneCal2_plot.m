function HeadphoneCal2_plot(caldata, figtitle)
%------------------------------------------------------------------------
% out = HeadphonCal2_init(caldata, figtitle)
%------------------------------------------------------------------------
% 
% Plots CAL data.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (PlotCal): 2008-2010 by SJS
% Upgraded Version Written (HeadphoneCal2_plot): 2011-2012 by GA
%------------------------------------------------------------------------

if ~isstruct(caldata)
    disp('invalid CAL data');
    return;
end
	
if ~isfield(caldata, 'Freqs')
    disp('invalid CAL frequency data: freq not found');
	return;
end
	
if isempty(caldata.Freqs)
    disp('invalid CAL frequency data: freq is empty');
	return; 
end

L = 1; 
R = 2;

% open figure window and set figure title 
figure;
if nargin > 1  % if figure title is provided, then set it
    set(gcf, 'name', figtitle);
end

subplot(3,2,1);
errorbar(caldata.Freqs, caldata.mag(L, :), caldata.mag_stderr(L, :), '.-g');
hold on;
errorbar(caldata.Freqs, caldata.mag(R, :), caldata.mag_stderr(R, :), '.-r');
hold off;
title('Calibration Results');
ylabel('Max Intensity (db SPL)');
legend('L', 'R');
xlim([caldata.F(1) caldata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,3);
errorbar(caldata.Freqs, unwrap(caldata.phase(L, :)), caldata.phase_stderr(L, :), '.-g');
hold on;
errorbar(caldata.Freqs, unwrap(caldata.phase(R, :)), caldata.phase_stderr(R, :), '.-r');
hold off;
ylabel('Phase');
legend('L','R');
xlim([caldata.F(1) caldata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,5);
errorbar(caldata.Freqs, caldata.dist(L, :)*100, caldata.dist_stderr(L, :)*100, '.-g');
hold on;
errorbar(caldata.Freqs, caldata.dist(R, :)*100, caldata.dist_stderr(R, :)*100, '.-r');
hold off;
ylabel('Distortion (%)');
legend('L', 'R');
xlim([caldata.F(1) caldata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,2);
errorbar(caldata.Freqs, caldata.leakmag(L, :), caldata.leakmag_stderr(L, :), '.-g');
hold on;
errorbar(caldata.Freqs, caldata.leakmag(R, :), caldata.leakmag_stderr(R, :), '.-r');
hold off;
ylabel('Leak magnitude (dB)');
legend('L','R');
xlim([caldata.F(1) caldata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,4);
errorbar(caldata.Freqs, unwrap(caldata.leakphase(L, :)), caldata.leakphase_stderr(L, :), '.-g');
hold on;
errorbar(caldata.Freqs, unwrap(caldata.leakphase(R, :)), caldata.leakphase_stderr(R, :), '.-r');
hold off;
ylabel('Leak phase');
legend('L','R');
xlim([caldata.F(1) caldata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,6);
errorbar(caldata.Freqs, caldata.leakdist(L, :)*100, caldata.leakdist_stderr(L, :)*100, '.-g');
hold on;
errorbar(caldata.Freqs, caldata.leakdist(R, :)*100, caldata.leakdist_stderr(R, :)*100, '.-r');
hold off;
ylabel('Leak distortion (%)');
legend('L','R');
xlim([caldata.F(1) caldata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

