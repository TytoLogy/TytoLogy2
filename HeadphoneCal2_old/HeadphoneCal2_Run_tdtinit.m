%--------------------------------------------------------------------------
% HeadphoneCal2_Run_tdtinit.m
%--------------------------------------------------------------------------
% initializes, loads, sets up TDT hardware and I/O parameters
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Originally Written (HeadphoneCal_tdtinit): 2008-2010 by SJS
% Renamed Version Created (HeadphoneCal2_Run_tdtinit): November, 2011 by GA
%
% Revisions: modified version for MicrophoneCal2
%   Feb, 2012: modified for RX6 (GA)
%--------------------------------------------------------------------------

disp('...starting TDT hardware...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the TDT devices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize RX8 
%tmpdev = RX8init('GB', iodev.Dnum);
tmpdev = RX6init2('GB', iodev.Dnum); % (GA) for U-Oldenburg, Feb/2012
iodev.C = tmpdev.C;
iodev.handle = tmpdev.handle;
iodev.status = tmpdev.status;
% Initialize PA5 attenuators (left = 1 and right = 2)
PA5L = PA5init('GB', 1);
PA5R = PA5init('GB', 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loads circuits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%iodev.rploadstatus = RPload(iodev);
iodev.rploadstatus = RPload2(iodev); % (GA) for U-Oldenburg, Feb/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starts Circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RPrun(iodev);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.status = RPcheckstatus(iodev);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the tags and values for the circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmptags = RPtagnames(iodev);
iodev.TagName = tmptags;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Query the sample rate from the circuit 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.Fs = RPsamplefreq(iodev);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up some of the buffer/stimulus parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
npts=150000;  % size of the serial buffer -- fixed
dt = 1/iodev.Fs;
mclock=RPgettag(iodev, 'mClock');
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
% RPsettag(iodev, 'ChannelB', XXX);  % this channel is not used
RPsettag(iodev, 'inChannelA', cal.InChanL); % L is channel A
RPsettag(iodev, 'inChannelB', cal.InChanR); % R is channel B
% set filters
RPsettag(iodev, 'HPFreq', cal.HPFreq);
RPsettag(iodev, 'HPenable', 1);
RPsettag(iodev, 'LPFreq', cal.LPFreq);
RPsettag(iodev, 'LPenable', 1);
% set TDTINIT to 1
TDTINIT = 1;

