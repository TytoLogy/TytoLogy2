%--------------------------------------------------------------------------
% HeadphoneCal2_Run_caldata_init.m
%--------------------------------------------------------------------------
%	Script for HeadphoneCal2 program to initialize/allocate caldata
%	structure for headphone speaker calibration
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Originally Written (HeadphoneCal_caldata_init): 2008-2010 by SJS
% Renamed Version Created (HeadphoneCal2_Run_caldata_init): November, 2011 by GA
%
% Revisions: modified version for HeadphoneCal2
% 
%--------------------------------------------------------------------------

cal = handles.h2.cal; % making a local copy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
caldata.version = '2.0';
caldata.time_str = datestr(now, 31);		% date and time
caldata.timestamp = now;				% timestamp
caldata.adFc = iodev.Fs;				% analog input rate 
caldata.daFc = iodev.Fs;				% analog output rate 
caldata.F = cal.F;					% freq range (matlab string)
caldata.Freqs = cal.Freqs;			% frequencies (matlab array)
caldata.Nfreqs = cal.Nfreqs;				% number of freqs to collect
caldata.Reps = cal.Reps;				% reps per frequency
caldata.cal = cal;                   % parameters for calibration session
caldata.frdataL = cal.frL;    % FR data
caldata.frdataR = cal.frR;    % FR data
caldata.frfileL = cal.frfileL;  % FR file name
caldata.frfileR = cal.frfileR;  % FR file name
caldata.DAlevel = cal.DAlevel;		% output peak voltage level
caldata.Side = cal.Side;
caldata.AttenType = cal.AttenType;
switch cal.AttenType
    case 'VARIED'
    caldata.Atten = cal.AttenStart;			% initial attenuator setting
    caldata.max_spl = cal.MaxLevel;			% maximum spl (will be determined in program)
    caldata.min_spl = cal.MinLevel;			% minimum spl (will be determined in program)
    case 'FIXED'
    caldata.Atten = cal.AttenFixed;			% initial attenuator setting
    caldata.max_spl = cal.AttenFixed;			% maximum spl (will be determined in program)
    caldata.min_spl = cal.AttenFixed;			% minimum spl (will be determined in program)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocate some arrays that are used locally
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpcell = cell(2, 1); % L = 1; R = 2;
tmpcell{1} = zeros(cal.Nfreqs, cal.Reps);
tmpcell{2} = zeros(cal.Nfreqs, cal.Reps);
tmprawmags = tmpcell;
tmpleakmags = tmpcell;
tmpphis = tmpcell;
tmpleakphis = tmpcell;
tmpdists = tmpcell;
tmpleakdists = tmpcell;
tmpdistphis = tmpcell;
tmpleakdistphis = tmpcell;
tmpmaxmags = tmpcell;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup data storage variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmparr = zeros(2, cal.Nfreqs); % L = 1; R = 2;
caldata.mag = tmparr;
caldata.mag_stderr = tmparr;
caldata.phase = tmparr;
caldata.phase_stderr = tmparr;
caldata.dist = tmparr;
caldata.dist_stderr = tmparr;
caldata.leakmag = tmparr;
caldata.leakmag_stderr = tmparr;
caldata.leakphase = tmparr;
caldata.leakphase_stderr = tmparr;
caldata.leakdist = tmparr;
caldata.leakdist_stderr = tmparr;
caldata.atten = tmparr;

