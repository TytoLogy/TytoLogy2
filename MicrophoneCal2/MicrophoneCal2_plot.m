function MicrophoneCal2_plot(frdata, figtitle)
%------------------------------------------------------------------------
% out = MicrophonCal2_init(frdata, figtitle)
%------------------------------------------------------------------------
% 
% Plots FR data.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (MicrophoneCal): 2008-2010 by SJS
% Upgraded Version Written (MicrophoneCal2_plot): 2011-2012 by GA
%
% Revisions: modified version for MicrophoneCal2
% 
%------------------------------------------------------------------------

if ~isstruct(frdata)
    disp('invalid FR data');
    return;
end
	
if ~isfield(frdata, 'Freqs')
    disp('invalid FR frequency data: freq not found');
	return;
end
	
if isempty(frdata.Freqs)
    disp('invalid FR frequency data: freq is empty');
	return; 
end

REF = 1; 
MIC = 2;

% open figure window and set figure title 
figure;
if nargin > 1  % if figure title is provided, then set it
    set(gcf, 'name', figtitle);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% non-normalized data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,2,1);
errorbar(frdata.Freqs, frdata.mag(REF, :), frdata.mag_stderr(REF, :), '.-k');
hold on;	
errorbar(frdata.Freqs, frdata.mag(MIC, :), frdata.mag_stderr(MIC, :), '.-g');
hold off;
title('Calibration Results');
ylabel('Magnitude');
legend('Ref', 'Mic');
xlim([frdata.F(1) frdata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,2);
errorbar(frdata.Freqs, frdata.phase(REF, :), frdata.phase_stderr(REF, :), '.-k');
hold on;
errorbar(frdata.Freqs, frdata.phase(MIC, :), frdata.phase_stderr(MIC, :), '.-g');
hold off;
ylabel('Phase');
legend('Ref','Mic');
xlim([frdata.F(1) frdata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normalized data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,2,3);
title('Normalized Frequency Response');
plot(frdata.Freqs, normalize(frdata.mag(REF, :)), '.-k');
hold on
plot(frdata.Freqs, normalize(frdata.mag(MIC, :)), '.-g');
hold off;
ylabel('Normalized Magnitude');
legend('Ref', 'Mic');
xlim([frdata.F(1) frdata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
%set(gca, 'Color', .5*[1 1 1]);

subplot(3,2,4);
plot(frdata.Freqs, unwrap(frdata.phase(REF, :)), '.-k');
hold on;
plot(frdata.Freqs, unwrap(frdata.phase(MIC, :)), '.-g');
hold off;
ylabel('Unwrapped Phase');
legend('Ref','Mic');
xlim([frdata.F(1) frdata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
%set(gca, 'Color', .5*[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FR data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,2,5);
plot(frdata.Freqs, frdata.adjmag(:), '.-g');
hold on;
hold off;
title('Correction Factor');
ylabel('AdjMagnitude');
xlabel('Frequency (Hz)');
legend('AdjMag');
xlim([frdata.F(1) frdata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');

subplot(3,2,6);
plot(frdata.Freqs, frdata.adjphi(:), '.-g');
hold on;
hold off;
ylabel('AdjPhase');
xlabel('Frequency (Hz)');
legend('AdjPhase');
xlim([frdata.F(1) frdata.F(3)]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');


