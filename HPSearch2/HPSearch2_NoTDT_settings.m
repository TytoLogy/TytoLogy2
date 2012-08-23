function Fs = HPSearch2_NoTDT_settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
% Fs = HPSearch2_NoTDT_settings(indev, outdev, tdt, stimulus)
%------------------------------------------------------------------------
% Dummy function to used with the NO_TDT configuration
% Sets up a dummy config data file (notdt.mat) and 
% Returns dummy sampling frequency data
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	indev			TDT device interface structure
% 	outdev			TDT device interface structure (not used)
% 	tdt             TDT setting parameter structure
%   stimulus        stimulus parameters structure
%   channels        I/O channels parameters structure
% 
% Output Arguments:
%	Fs				[1 X 2] sampling rate for input (1) and output (2)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (HPSearch2_NoTDT_setting): Mar 2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

Fs = [50000 50000];

notdt.stimulus = stimulus;
notdt.tdt = tdt;
notdt.Fs = Fs;
save notdt.mat -mat notdt;

