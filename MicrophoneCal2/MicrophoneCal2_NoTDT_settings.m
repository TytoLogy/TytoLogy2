function MicrophoneCal2_NoTDT_settings(iodev, cal)
%------------------------------------------------------------------------
% MicrophoneCal2_NoTDT_settings(iodev, cal)
%------------------------------------------------------------------------
% Dummy function to used with the NO_TDT configuration
% Sets up a dummy config data file (notdt.mat) 
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	iodev			TDT device interface structure
% 	cal             calibration data structure
% 
% Output Arguments:
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (MicrophoneCal2_NoTDT_settings): 2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

notdt.Fs = 50000;
notdt.Delay = cal.Delay;
save notdt.mat -mat notdt;

