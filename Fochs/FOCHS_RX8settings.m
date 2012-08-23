function Fs = FOCHS_RX8settings(indev, outdev, tdt, stimulus, channels)
% Fs = FOCHS_RX8settings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
%
% Sets up TDT settings for HPSearch using RX8 for input and output
% 
%------------------------------------------------------------------------
% designed to use with RPVD circuit: 
%               RX8_50k_FourChannelInput.rcx
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
%  Go Ashida & Sharad Shanbhag 
%   ashida@umd.edu
%   sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (HPSearch_RX8iosettings): 2009-2011 by SJS
% Upgraded Version (HPSearch2_RX8settings): 2011-2012 by GA
% Four-channel Input Version (FOCHS_RX8settings): 2012 by GA  
%------------------------------------------------------------------------

% RX8 is used for both input and output
iodev = indev;

% query the sample rate from the circuit
inFs = RPsamplefreq(iodev);
outFs = inFs; 
Fs = [inFs outFs];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input/Output Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the Stimulus Delay
RPsettag(iodev, 'StimDelay', ms2bin(stimulus.Delay, outFs));
% Set the Stimulus Duration
RPsettag(iodev, 'StimDur', ms2bin(stimulus.Duration, outFs));
% Set the length of time to acquire data
RPsettag(iodev, 'AcqDur', ms2bin(tdt.AcqDuration, inFs));
% Set the total sweep period time
RPsettag(iodev, 'SwPeriod', ms2bin(tdt.SweepPeriod, inFs));
% set the TTL pulse duration
RPsettag(iodev, 'TTLPulseDur', ms2bin(tdt.TTLPulseDur, inFs));
% set the high pass filter
RPsettag(iodev, 'HPenable', 1);
RPsettag(iodev, 'HPFreq', tdt.HPFreq);
% set the low pass filter
RPsettag(iodev, 'LPenable', 1);
RPsettag(iodev, 'LPFreq', tdt.LPFreq);
% set input channels 
RPsettag(iodev, 'inChannelA', channels.InputChannel1); 
RPsettag(iodev, 'inChannelB', channels.InputChannel2); 
RPsettag(iodev, 'inChannelC', channels.InputChannel3); 
RPsettag(iodev, 'inChannelD', channels.InputChannel4); 
% set output channels 
RPsettag(iodev, 'ChannelA', channels.OutputChannelL); 
RPsettag(iodev, 'ChannelB', channels.OutputChannelR); 
% Set the sweep count to 1
RPsettag(iodev, 'SwCount', 1);

