function [resp, npts, respu, nptsu] = HPSearch2_spikeio(stim, inpts, indev, outdev, zBUS)
% [resp, idx, respu, nptsu] = HPSearch2_spikeio(stim, inpts, iodev, outdev, zBUS)
% 
% Plays stim array out channels A and B, and records inputs (spikes, etc.)
%
% designed to use with RPVD circuit: 
%               RX8_3_SingleChannelFiltUnfilt 
%               RX6_50k_SingleChannelFiltUnfilt
% 
% Input Arguments:
% 	stim        [2xN] stereo output signal (row1 = left, row2 = right)
% 	inpts		number of points to acquire
% 	indev		TDT device interface structure for input & output
% 	outdev		TDT device interface structure for output (not used)
% 	zBUS		TDT device interface structure for zBUS (not used)
% 
% Output Arguments:
% 	resp	[1xinpts] input data vector (or 1Xindex if something weird happens
% 	npts	number of data points read (resp = channel A)
%   respu   [1xinpts] input data vector (unfiltered)
%   nptsu   number of data points read (respu = channel B)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%	sshanbha@aecom.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version Written (headphone_spikeio): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_spikeio): 2011-2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

% RX8 is used for both input and output
iodev = indev; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset before playing sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of output points
outpts = length(stim);
% Send reset command (software trigger 3)
RPtrig(iodev, 3);
% Set the output buffer length
RPsettag(iodev, 'StimDur', outpts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Play sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load output buffer
out_msg = RPwriteV(iodev, 'data_outA', stim(1, :));
out_msg = RPwriteV(iodev, 'data_outB', stim(2, :));
% Send start command (software trigger 1)
RPtrig(iodev, 1);
% Main Loop
sweep_end = RPfastgettag(iodev, 'SwpEnd');
while(sweep_end==0)
	sweep_end = RPfastgettag(iodev, 'SwpEnd');
end
sweepCount = RPfastgettag(iodev, 'SwpN');
% stop playing (software trigger 2)
RPtrig(iodev, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data from the buffers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inptsA = inpts;
inptsB = inpts;
% --- filtered data : channel A
npts = RPgettag(iodev, 'index_inA'); % get the current location in the buffer
if npts < inptsA
	inptsA = npts;
end
%reads filtered data from the buffer
resp = RPreadV(iodev, 'data_inA', inptsA);

% --- unfiltered data : channel B
nptsu = RPgettag(iodev, 'index_inB'); % get the current location in the buffer
if nptsu < inptsB
	inptsB = nptsu;
end
%reads unfiltered data from the buffer
respu = RPreadV(iodev, 'data_inB', inptsB);

