function [resp, index] = hp2_calibration_io(iodev, stim, inpts)
% [resp, index] = hp2_calibration_io(iodev, stim, inpts)
% 
% for use with RPVD circuit RX8_3_TwoChannelInOut or RX6
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
% See also: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%	sshanbha@aecom.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Originally Written (headphone_io): 2008-2010 by SJS
% Renamed Version Created (hp2_calibration_io): November, 2011 by GA
%
% Revisions:
%
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup before playing sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maximum # of input and output points
max_outpts = 150000;
max_inpts = 150000;
% check to make sure the length of the output signal is inside limit
outpts = length(stim);
if ~between(outpts, 1, max_outpts)
	warning('length of stim out of range!');
	resp = 0;
	index = 0;
	return;
end
if ~between(inpts, 0, max_inpts) 
	warning('inpts out of range');
	inpts = outpts;
end
% send reset command (software trigger 3)
RPtrig(iodev, 3);
% set the output buffer length
RPsettag(iodev, 'StimDur', outpts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Play sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load output buffer
out_msg = RPwriteV(iodev, 'data_outA', stim(1, :));
out_msg = RPwriteV(iodev, 'data_outB', stim(2, :));
% send start command (software trigger 1)
RPtrig(iodev, 1);
% Main Loop
sweep_end = RPgettag(iodev, 'SwpEnd');
while(sweep_end==0)
	sweep_end = RPgettag(iodev, 'SwpEnd');
end
sweepCount = RPgettag(iodev, 'SwpN');
% stop playing (software trigger 2)
RPtrig(iodev, 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data from buffers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the current location in the buffer
index(1) = RPgettag(iodev, 'index_inA');
index(2) = RPgettag(iodev, 'index_inB');
%reads from the buffer
resp{1} = RPreadV(iodev, 'data_inA', inpts);
resp{2} = RPreadV(iodev, 'data_inB', inpts);


