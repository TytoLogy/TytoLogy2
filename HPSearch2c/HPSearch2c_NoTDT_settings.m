function Fs = HPSearch2c_NoTDT_settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
% Fs = HPSearch2c_NoTDT_settings(indev, outdev, tdt, stimulus, channels)
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
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (HPSearch2_NoTDT_settings): Mar 2012 by GA
% Adopted for HPSearch2a (HPSearch2a_NoTDT_settings): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_NoTDT_settings): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_NoTDT_settings): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

Fs = [50000 50000];

notdt.stimulus = stimulus;
notdt.tdt = tdt;
notdt.Fs = Fs;
save notdt.mat -mat notdt;

