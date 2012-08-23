function Fs = FOCHS_NoTDT_settings(indev, outdev, tdt, stimulus, channels)
% Fs = FOCHS_NoTDT_settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
%
% Dummy function to used with the NO_TDT configuration
% Sets up a dummy config data file (notdt.mat) and 
% Returns dummy sampling frequency data
% 
%------------------------------------------------------------------------
% Input Arguments:
%   indev       TDT device interface structure
%   outdev      TDT device interface structure (not used)
%   tdt         TDT setting parameter structure
%   stimulus    stimulus parameters structure
%   channels    I/O channels parameters structure 
% Output Arguments:
%    Fs         [1X2] sampling rates for input (1) and output (2)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (HPSearch2_NoTDT_setting): Mar 2012 by GA
% Four-channel Input Version (FOCHS_NoTDT_settings): May 2012 by GA  
%------------------------------------------------------------------------

Fs = [50000 50000];

notdt.stimulus = stimulus;
notdt.tdt = tdt;
notdt.Fs = Fs;
save notdt.mat -mat notdt;
