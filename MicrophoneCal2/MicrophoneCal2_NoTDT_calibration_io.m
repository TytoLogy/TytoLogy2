function [resp, index] = MicrophoneCal2_NoTDT_calibation_io(iodev, stim, inpts)
% [resp, index] = MicrophoneCal2_NoTDT_calibration_io(iodev, stim, inpts)
% 
% Dummy function to used with the NO_TDT configuration
% Returns dummy response data
%
% Input Arguments:
% 	iodev	TDT input/output device interface structure
%	stim	[2XN] stimulus array, L channel in row 1, R channel in row 2
%	inpts	# of points to record from input channels (AcqPoints)
% 
% Output Arguments:
% 	resp	2 element response cell array
%	index	buffer size
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (MicrophoneCal2_NoTDT_calibration_io): Apr 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

load notdt.mat;  % loading the notdt structure
nFs = notdt.Fs;  
nDelay = ms2samples(notdt.Delay, nFs);
clear notdt; 

amp = std(stim,0,2); 
tmpa = max([0.1 amp(1)]);
tmpr = 0.2*tmpa*randn(1,inpts);

outstim = [ zeros(2,nDelay), stim ]; % introducing delay
outpts = length(outstim);

if outpts > inpts
     tmpr  = tmpr + outstim(1,1:inpts);
else
     tmpr(1,1:outpts)  = tmpr(1,1:outpts)  + outstim(1,:); 
end

resp{1} = 50e-6*tmpr(1,1:inpts);
resp{2} = 20*(4+rand(1,1))*resp{1} + 2e-3*tmpa*randn(1,inpts);
index = [inpts inpts];

