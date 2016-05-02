function Fs = FOCHS_RZ6RZ5Dsettings(indev, outdev, tdt, stimulus, channels)
% Fs = FOCHS_RZ6RZ5Dsettings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
%
% Sets up TDT settings for HPSearch using 
% 	RZ52 (via PZ2) for spike input 
% 			- and -
% 	RZ6 for stimulus output
% 
%------------------------------------------------------------------------
% designed to use with RPVD circuits: 
%		RZ5D_50k_FourChannelInput_zBus.rcx
% 		RZ6_2Processor_SpeakerOutput_zBus.rcx
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
% Go Ashida & Sharad Shanbhag 
% ashida@umd.edu
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (HPSearch_RX8iosettings): 2009-2011 by SJS
% Upgraded Version (HPSearch2_RX8settings): 2011-2012 by GA
% Four-channel Input Version (FOCHS_RX8settings): 2012 by GA  
% Optogen Version (FOCHS_RZ6RZ5Dsettings): 2016 by SJS  
%------------------------------------------------------------------------

% query the sample rate from the circuit
inFs = RPsamplefreq(indev);
outFs = RPsamplefreq(outdev); 
Fs = [inFs outFs];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input/output Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the Stimulus Delay
RPsettag(outdev, 'StimDelay', ms2bin(stimulus.Delay, outFs));
% Set the Stimulus Duration
RPsettag(outdev, 'StimDur', ms2bin(stimulus.Duration, outFs));
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(tdt.AcqDuration, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(tdt.SweepPeriod, inFs));
RPsettag(indev, 'SwPeriod', ms2bin(tdt.SweepPeriod, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(tdt.SweepPeriod, outFs));
RPsettag(outdev, 'SwPeriod', ms2bin(tdt.SweepPeriod, outFs));
% set the TTL pulse duration
RPsettag(indev, 'TTLPulseDur', ms2bin(tdt.TTLPulseDur, inFs));
% set the TTL pulse duration
RPsettag(outdev, 'TTLPulseDur', ms2bin(tdt.TTLPulseDur, outFs));
% set the high pass filter
RPsettag(indev, 'HPenable', 1);
RPsettag(indev, 'HPFreq', tdt.HPFreq);
% set the low pass filter
RPsettag(indev, 'LPenable', 1);
RPsettag(indev, 'LPFreq', tdt.LPFreq);
% set input channels 
RPsettag(indev, 'inChannelA', channels.InputChannel1); 
RPsettag(indev, 'inChannelB', channels.InputChannel2); 
RPsettag(indev, 'inChannelC', channels.InputChannel3); 
RPsettag(indev, 'inChannelD', channels.InputChannel4); 
% set output channels 
RPsettag(outdev, 'ChannelA', channels.OutputChannelL); 
RPsettag(outdev, 'ChannelB', channels.OutputChannelR); 
% Set the sweep count to 1
RPsettag(indev, 'SwCount', 1);
RPsettag(outdev, 'SwCount', 1);

