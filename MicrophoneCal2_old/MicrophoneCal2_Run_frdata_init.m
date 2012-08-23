%--------------------------------------------------------------------------
% MicrophoneCal2_Run_frdata_init.m
%--------------------------------------------------------------------------
%	Script to initialize/allocate frdata structure that holds the microphone
%	frequency response calibration data for the earphone microphones
%--------------------------------------------------------------------------
% Data Format:
% 
% 	frdata fields: 
% 	
% 			FIELD       FMT		   DESCRIPTION	
%           version: (str)          data version
%          time_str: (str)			date and time of data collection
%         timestamp: (dbl)			matlab timestamp at start of data acq.
%              adFc: (dbl)			analog-digital conversion rate for data
%              daFc: (dbl)			digital-analog conversion rate for signals
%                 F: [1X3 dbl]		array of Fmin Fstep Fmax freqs
%             Freqs: (dbl array)	array of frequencies tested
%            Nfreqs: (dbl)			# of frequencies tested
%              Reps: (dbl)			# of reps at each frequency
%               cal: (struct)		calibration settings structure (see MicrophoneCal_settings.m)
%             Atten: (dbl)			attenuator setting, dB
%           max_spl: (dbl)			maximum dB SPL level
%           min_spl: (dbl)			minimum dB SPL signal level
% 		    DAlevel: (dbl)			scaling factor for output signal in Volts
%
%              freq: [1x473 dbl]	frequencies
%               mag: [3x473 dbl]	magnitude data, (Left Vrms, Right Vrms, Ref VRMS)
%             phase: [3x473 dbl]	phase data (degrees)
%              dist: [3x473 dbl]	mag. distortion data (2nd harmonic)
%        mag_stderr: [3x473 dbl]	magnitude std. error.
%      phase_stderr: [3x473 dbl]	phase std. error
%        background: [3x2 dbl]	Background RMS level, Volts, (L, R, Ref channels)
%     bkpressureadj: [1x473 dbl]	ref. mic correction factor for pressure field measurements
%           ladjmag: [1x473 dbl]	L channel microphone magnitude correction factor (Vrms/Pascal_rms)
%           radjmag: [1x473 dbl]	R channel microphone magnitude correction factor (Vrms/Pascal_rms)
%           ladjphi: [1x473 dbl]	L channel microphone phase correction factor (deg)
%           radjphi: [1x473 dbl]	R channel microphone phase correction factor (deg)
% 
% 		microphone adjust factors are:
% 			magnitude adj = knowles mic Vrms / Ref mic Vrms
% 			phase adj = Knowls mic deg - ref mic degrees
% 
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Originally Written (MicrophoneCal_frdata_init): 2008-2010 by SJS
% Renamed Version Created (MicrophoneCal2_Run_frdata_init): November, 2011 by GA
%
% Revisions: modified version for MicrophoneCal2
% 
%--------------------------------------------------------------------------

cal = handles.h2.cal; % making a local copy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frdata.version = '2.0';
frdata.time_str = datestr(now, 31);		% date and time
frdata.timestamp = now;				% timestamp
frdata.adFc = iodev.Fs;				% analog input rate 
frdata.daFc = iodev.Fs;				% analog output rate 
frdata.F = cal.F;					% freq range (matlab string)
frdata.Freqs = cal.Freqs;			% frequencies (matlab array)
frdata.Nfreqs = cal.Nfreqs;				% number of freqs to collect
frdata.Reps = cal.Reps;				% reps per frequency
frdata.cal = cal;                   % parameters for calibration session
frdata.Atten = cal.Atten;			% initial attenuator setting
frdata.max_spl = 0;					% maximum spl (will be determined in program)
frdata.min_spl = 0;					% minimum spl (will be determined in program)
frdata.DAlevel = cal.DAlevel;		% output peak voltage level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup data storage variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up the arrays to hold the data
background = cell(2,1); % REF = 1; MIC = 2; 
background{1} = zeros(1, cal.Reps);
background{2} = zeros(1, cal.Reps);

tmpcell = cell(2,1);  % REF = 1; MIC = 2; 
tmpcell{1} = zeros(cal.Nfreqs, cal.Reps);
tmpcell{2} = zeros(cal.Nfreqs, cal.Reps);
tmpmags = tmpcell;
tmpphis = tmpcell;
tmpdists = tmpcell;

% initialize the frdata structure arrays for the calibration data
frdata.background = zeros(2, 2);
tmparr = zeros(2, cal.Nfreqs); % REF = 1; MIC = 2;
frdata.mag = tmparr;
frdata.phase = tmparr;
frdata.dist = tmparr;
frdata.mag_stderr = tmparr;
frdata.phase_stderr = tmparr;
%%frdata.rawmags = tmp; %% what is this for?

% setup cell for raw data 
rawdata.Freqs = frdata.Freqs;
rawdata.background = cell(1, cal.Reps);
rawdata.resp = cell(cal.Nfreqs, cal.Reps);

