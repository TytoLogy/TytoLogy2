function HeadphoneCal2_NoTDT_settings(iodev, cal)
%------------------------------------------------------------------------
% HeadphoneCal2_NoTDT_settings(iodev, cal)
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
% Created (HeadphoneCal2_NoTDT_settings): 2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

notdt.cal = cal;
save notdt.mat -mat notdt;

