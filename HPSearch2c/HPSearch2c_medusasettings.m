function Fs = HPSearch2c_medusasettings(indev, outdev, tdt, stimulus, channels)
%------------------------------------------------------------------------
% Fs = HPSearch2c_medusasettings(indev, outdev, tdt, stimulus)
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
%  Fanny Cazetts, Sharad Shanbhag & Go Ashida
%   fanny.cazettes@phd.einstein.yu.edu
%   sshanbhag@neomed.edu
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version Written (HPSearch_medusasettings): 2009-2011 by SJS
% Upgraded Version (HPSearch2_medusasettings): Jul 2012 by FC
% Adopted for HPSearch2a (HPSearch2a_medusasettings): Sep 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_medusasettings): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_medusasettings): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

% Query the sample rate from the circuit
inFs = RPsamplefreq(indev);
outFs = RPsamplefreq(outdev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the total sweep period time
RPsettag(indev, 'SwPeriod', ms2samples(tdt.SweepPeriod, inFs));
% Set the sweep count to 1
RPsettag(indev, 'SwCount', 1);
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2samples(tdt.AcqDuration, inFs));

% set the HeadstageGain
RPsettag(indev, 'mcGain', 1000);
% get the buffer index
RPgettag(indev, 'mcIndex');

% set the HP filter
RPsettag(indev, 'HPEnable', tdt.HPEnable);
RPsettag(indev, 'HPFreq', tdt.HPFreq);

% set the LP filter
RPsettag(indev, 'LPEnable', tdt.LPEnable);
RPsettag(indev, 'LPFreq', tdt.LPFreq);

% Set the monitor D/A channel on RX5 and monitor gain
RPsettag(indev, 'MonChan', 2); 
RPsettag(indev, 'MonChannel', 1); 
RPsettag(indev, 'MonGain', tdt.MonitorGain); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the total sweep period time
RPsettag(outdev, 'SwPeriod', ms2samples(tdt.SweepPeriod, outFs));
% Set the sweep count to 1
RPsettag(outdev, 'SwCount', 1);
% Set the Stimulus Delay
RPsettag(outdev, 'StimDelay', ms2samples(stimulus.Delay, outFs));
% Set the Stimulus Duration
RPsettag(outdev, 'StimDur', ms2samples(stimulus.Duration, outFs));
	
Fs = [inFs outFs];
