function Fs = HPSearch2_RX8settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
% Fs = HPSearch2_RX8settings(indev, outdev, tdt, stimulus)
%------------------------------------------------------------------------
% sets up TDT settings for HPSearch using RX8 for input and output
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
%  Sharad Shanbhag & Go Ashida
%	sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Originally Written (HPSearch_RX8iosettings): 2009-2011 by SJS
% Renamed Version Created (HPSearch2_RX8settings): 2011-2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

% RX8 is used for both input and output
iodev = indev;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assuming that this program is used with the 
% 'RX8_3_SingleChannelFiltUnfilt.rcx' circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Query the sample rate from the circuit
inFs = RPsamplefreq(iodev);
outFs = inFs; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input/Output Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the TTL pulse duration
RPsettag(iodev, 'TTLPulseDur', ms2samples(tdt.TTLPulseDur, inFs));
% Set the total sweep period time
RPsettag(iodev, 'SwPeriod', ms2samples(tdt.SweepPeriod, inFs));
% Set the sweep count to 1
RPsettag(iodev, 'SwCount', 1);
% Set the length of time to acquire data
RPsettag(iodev, 'AcqDur', ms2samples(tdt.AcqDuration, inFs));
% Set the Stimulus Delay
RPsettag(iodev, 'StimDelay', ms2samples(stimulus.Delay, outFs));
% Set the Stimulus Duration
RPsettag(iodev, 'StimDur', ms2samples(stimulus.Duration, outFs));
% set input channel (single)
RPsettag(iodev, 'inChannel', channels.InputChannel); %
% set output channels 
RPsettag(iodev, 'ChannelA', channels.OutputChannelL); 
RPsettag(iodev, 'ChannelB', channels.OutputChannelR); 
% set the high pass filter
RPsettag(iodev, 'HPenable', 1);
RPsettag(iodev, 'HPFreq', tdt.HPFreq);
% set the low pass filter
RPsettag(iodev, 'LPenable', 1);
RPsettag(iodev, 'LPFreq', tdt.LPFreq);

Fs = [inFs outFs];
