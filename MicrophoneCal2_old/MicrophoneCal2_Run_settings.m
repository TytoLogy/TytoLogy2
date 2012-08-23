%--------------------------------------------------------------------------
% MicrophoneCal2_Run_settings.m
%--------------------------------------------------------------------------
%
%	Edit this file to set frequency range, amplitude, etc
%	for calibrating the earphone microphones with a reference
%	(e.g., Bruel & Kjaer / B&K) microphone
%
%--------------------------------------------------------------------------
% cal fields:
% 
%               Fmin: (dbl)		min frequency (Hz)
% 			    Fmax: (dbl)		max frequency (Hz)
%              Fstep: (dbl)		frequency step (Hz)
%               Reps: (int)		# reps per freq.
%              Atten: (dbl)		attenuator setting (dB)
%
%            DAlevel: (dbl)		output voltage scale factor (V)
%         RefMicSens: (dbl)		reference microphone Sensitivity (Volts/Pascal)
%              VtoPa: (dbl)		Reference Microphone Volts to Pascal conv. factor
%         RefGain_dB: (dbl)	    reference microphone gain (db) 
%            RefGain: (dbl)	    ref mic gain multi. factor
%         MicGain_dB: (dbl)	    calibrated microphone gain (db), 
%            MicGain: (dbl)	    cal mic gain multi. factor
%          FieldType: (str)		calibration condition, 'PRESSURE' or 'FREE'
%
%         OutChannel: (int)		output speaker channel
%         RefChannel: (int)		reference mic channel 
%         MicChannel: (int)		channel being calibrated 
%
%                ISI: (dbl)		stimulus interval (msec)
%           Duration: (dbl)		stimulus duration (msec)
%              Delay: (dbl)		stimulus delay (msec)
%               Ramp: (dbl)		stimulus ramp on/off time (msec)
%        AcqDuration: (dbl)		Acquisition time (msec)
%        SweepPeriod: (dbl)		total sweep period (msec)
%        TTLPulseDur: (dbl)		TTL sync pulse duration (msec)
%
%             HPfreq: (dbl)     Input high-pass filter freq.
%             LPfreq: (dbl)     Input low-pass filter freq.
%
%              timer: (dbl)		time duration (seconds) for calibration
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Originally Written (MicrophoneCal_settings): 2008-2010 by SJS
% Renamed Version Created (MicrophoneCal2_Run_settings): November, 2011 by GA
%
% Revisions: modified version for MicrophoneCal2
% 
%--------------------------------------------------------------------------

disp('...general setup starting...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% general constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
REF = 1; 
MIC = 2;
MAX_ATTEN = 120;
CLIPVAL = 10; 	% clipping value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set this to wherever the circuits are stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.Circuit_Path = 'C:\TytoLogy2\toolbox2\'; 
%iodev.Circuit_Name = 'RX8_3_TwoChannelInOut'; % for UMD
iodev.Circuit_Name = 'RX6_50k_TwoChannelInOut'; % (GA) for U-Oldenburg, Feb/2012
iodev.status = 0;
iodev.Dnum = 1; % device number 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibration Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cal = handles.h2.cal; % making a local copy
cal.VtoPa = cal.RefMicSens^-1;  % Volts to Pascal factor
cal.RefGain = 10^(cal.RefGain_dB/20); % ref gain factor
cal.MicGain = 10^(cal.MicGain_dB/20); % mic gain factor
cal.ISI = 100; 
cal.Duration = 150;
cal.Delay = 10;
cal.Ramp = 5;
cal.AcqDuration = 200;
cal.SweepPeriod = cal.AcqDuration + 10;
cal.TTLPulseDur = 1;
cal.HPFreq = 100;
cal.LPFreq = 16000;

cal.F = [cal.Fmin cal.Fstep cal.Fmax];
cal.Freqs = cal.Fmin : cal.Fstep : cal.Fmax;
cal.Nfreqs = length(cal.Freqs);

cal.RMSsin = 1/sqrt(2);  % pre-compute the sinusoid RMS factor

% save handles structure
handles.h2.cal = cal; 
guidata(hObject, handles);	
