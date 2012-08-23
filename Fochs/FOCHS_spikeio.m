function [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4] = ...
    FOCHS_spikeio(stim, inpts, indev, outdev, zBUS)
% [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4] = ...
%    FOCHS_spikeio(stim, inpts, indev, outdev, zBUS)
%------------------------------------------------------------------------
%
% Plays stim array through out channels A and B, 
% and records data from four input channels (A-D). 
%
%------------------------------------------------------------------------
% designed to use with RPVD circuit: 
%               RX8_50k_FourChannelInput.rcx
%------------------------------------------------------------------------
% Input Arguments:
%   stim    [2xN] stereo output signal (row1 = left, row2 = right)
%   inpts   number of points to acquire
%   indev   TDT device interface structure for input & output
%   outdev  TDT device interface structure for output (not used)
%   zBUS    TDT device interface structure for zBUS (not used)
% 
% Output Arguments:
%   respX    [1xinpts] input data vector (X=1-4)
%   nptsX    number of data points read (X=1-4)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%   sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (headphone_spikeio): 2009-2011 by SJS
% Upgraded Version (HPSearch2_spikeio): 2011-2012 by GA
% Four-channel Input Version (FOCHS_spikeio): 2012 by GA  
%------------------------------------------------------------------------

% RX8 is used for both input and output
iodev = indev; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset before playing sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of output points
outpts = length(stim);
% send RESET command (software trigger 3)
RPtrig(iodev, 3);
% set the output buffer length
RPsettag(iodev, 'StimDur', outpts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Play sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load output buffer
out_msg = RPwriteV(iodev, 'data_outA', stim(1, :));
out_msg = RPwriteV(iodev, 'data_outB', stim(2, :));
% send START command (software trigger 1)
RPtrig(iodev, 1);
% main Loop
sweep_end = RPfastgettag(iodev, 'SwpEnd');
while(sweep_end==0)
    sweep_end = RPfastgettag(iodev, 'SwpEnd');
end
sweepCount = RPfastgettag(iodev, 'SwpN');
% send STOP command (software trigger 2)
RPtrig(iodev, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data from the buffers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inpts1 = inpts;
inpts2 = inpts;
inpts3 = inpts;
inpts4 = inpts;

% --- channel A = 1
% get the current location in the buffer
npts1 = RPgettag(iodev, 'index_inA'); 
if npts1 < inpts1
    inpts1 = npts1;
end
% read data from the buffer
resp1 = RPreadV(iodev, 'data_inA', inpts1);

% --- channel B = 2
% get the current location in the buffer
npts2 = RPgettag(iodev, 'index_inB'); 
if npts2 < inpts2
    inpts2 = npts2;
end
% read data from the buffer
resp2 = RPreadV(iodev, 'data_inB', inpts2);

% --- channel C = 3
% get the current location in the buffer
npts3 = RPgettag(iodev, 'index_inC'); 
if npts3 < inpts3
    inpts3 = npts3;
end
% read data from the buffer
resp3 = RPreadV(iodev, 'data_inC', inpts3);

% --- channel D = 4
% get the current location in the buffer
npts4 = RPgettag(iodev, 'index_inD'); 
if npts4 < inpts4
    inpts4 = npts4;
end
% read data from the buffer
resp4 = RPreadV(iodev, 'data_inD', inpts4);

