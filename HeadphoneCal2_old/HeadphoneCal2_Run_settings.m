%--------------------------------------------------------------------------
% HeadphoneCal2_Run_settings.m
%--------------------------------------------------------------------------
%
%	Edit this file to set frequency range, amplitude, etc
%
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
L = 1; 
R = 2;
%B = 3;
MAX_ATTEN = 120;
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
cal.RefMicSens = [cal.frL.cal.RefMicSens cal.frR.cal.RefMicSens];
cal.VtoPa = cal.RefMicSens.^-1;  % Volts to Pascal factor
cal.MicGain_dB = [cal.frL.cal.MicGain_dB cal.frR.cal.MicGain_dB];
cal.MicGain = 10.^(cal.MicGain_dB./20); % mic gain factor
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

