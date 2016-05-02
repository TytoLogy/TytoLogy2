function Fs = HPSearch2c_RX6settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
% Fs = HPSearch2c_RX6settings(indev, outdev, tdt, stimulus)
%------------------------------------------------------------------------
% sets up TDT settings for HPSearch2 using RX8 for input and output
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
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (HPSearch2_RX6settings): Mar 2012 by GA
% Adopted for HPSearch2a (HPSearch2a_RX6settings): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_RX6settings): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_RX6settings): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

% Parameter settings for RX6 are assumed to be the same as for RX8
Fs = HPSearch2c_RX8settings(indev, outdev, tdt, stimulus, channels); 

