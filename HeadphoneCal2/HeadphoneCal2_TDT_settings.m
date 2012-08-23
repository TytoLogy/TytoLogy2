function HeadphoneCal2_TDT_settings(iodev, cal)
%------------------------------------------------------------------------
% HeadphoneCal2_TDT_settings(iodev, cal)
%------------------------------------------------------------------------
% sets up TDT tag settings for MicrophoneCal2 
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	iodev			TDT device interface structure
% 	cal             calibration data structure
% 
% Output Arguments:
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%	sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Originally Written (HeadphoneCal_tdtinit): 2009-2011 by SJS
% Upgraded Version Written (HeadphoneCal2_TDTsettings): 2011-2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

%npts = 150000;  % size of the serial buffer -- fixed
%mclock = config.RPgettagFunc(iodev, 'mClock');

% set the TTL pulse duration
RPsettag(iodev, 'TTLPulseDur', ms2samples(cal.TTLPulseDur, iodev.Fs));
% set the total sweep period time
RPsettag(iodev, 'SwPeriod', ms2samples(cal.SweepPeriod, iodev.Fs));
% set the sweep count (may not be necessary)
RPsettag(iodev, 'SwCount', 1);
% Set the length of time to acquire data
RPsettag(iodev, 'AcqDur', ms2samples(cal.AcqDuration, iodev.Fs));
% set the stimulus delay
RPsettag(iodev, 'StimDelay', ms2samples(cal.Delay, iodev.Fs));
% set the stimulus Duration
RPsettag(iodev, 'StimDur', ms2samples(cal.Duration, iodev.Fs));
% set channels
RPsettag(iodev, 'ChannelA', cal.OutChanL);
RPsettag(iodev, 'ChannelB', cal.OutChanR);
RPsettag(iodev, 'inChannelA', cal.InChanL); % L is channel A
RPsettag(iodev, 'inChannelB', cal.InChanR); % R is channel B
% set filters
RPsettag(iodev, 'HPFreq', cal.HPFreq);
RPsettag(iodev, 'HPenable', 1);
RPsettag(iodev, 'LPFreq', cal.LPFreq);
RPsettag(iodev, 'LPenable', 1);

