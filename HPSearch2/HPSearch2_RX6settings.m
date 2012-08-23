function Fs = HPSearch2_RX6settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
% Fs = HPSearch2_RX6settings(indev, outdev, tdt, stimulus)
%------------------------------------------------------------------------
% sets up TDT settings for HPSearch using RX8 for input and output
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	indev			TDT device interface structure
% 	outdev			TDT device interface structure
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
% Created (HPSearch2_RX6settings): 2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

% Parameter settings for RX6 are assumed to be the same as for RX8
Fs = HPSearch2_RX8settings(indev, outdev, tdt, stimulus, channels); 

