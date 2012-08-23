function out = HeadphoneCal2_init(stype)
%------------------------------------------------------------------------
% out = MicrophonCal2_init(stype)
%------------------------------------------------------------------------
% 
% Sets initial values, etc.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Originally Written (HeadphoneCal): 2009-2011 by SJS
% Renamed Version Created (HeadphoneCal2_init): November, 2011 by GA
%
% Revisions: modified version for HeadphoneCal2
%   Feb, 2012: modifed for RX6
%------------------------------------------------------------------------

stype = upper(stype);

switch stype
    case 'INIT'  %%% edit the line below to get desired settings
%    out = 'RX8:DEFAULT';  % for RX8
    out = 'RX6:DEFAULT';  % for RX6 (U-Oldenburg)
    return;
    
	case 'RX8:DEFAULT'	 % for RX8
    disp('RX8:DEFAULT selected');
    out.Fmin = 400;
    out.Fmax = 12000;
    out.Fstep = 200;
    out.Reps = 3;
    out.Side = 'BOTH';
%    out.Side = 'LEFT';
    out.AutoSave = 1;

    out.AttenType = 'VARIED';
%    out.AttenType = 'FIXED';
    out.MinLevel = 45;
    out.MaxLevel = 50;
    out.AttenStep = 2;
    out.AttenFixed = 60;
    out.AttenStart = 90; 

    out.DAlevel = 5;
%    out.RefMicSens = 0.01;
    out.MicGainL_dB = 40;
    out.MicGainR_dB = 40;
    out.frfileL = [];
    out.frfileR = [];
%    out.loadedL = 0;
%    out.loadedR = 0;
    
    out.OutChanL = 17;
    out.OutChanR = 18;
    out.InChanL = 1;
    out.InChanR = 2;
	out.ISI = 100;
    return;

	case 'RX6:DEFAULT'	 % for RX6
    disp('RX6:DEFAULT selected');
    out.Fmin = 400;
    out.Fmax = 12000;
    out.Fstep = 200;
    out.Reps = 3;
    out.Side = 'LEFT';
    out.AutoSave = 1;
    
    out.AttenType = 'VARIED';
    out.MinLevel = 45;
    out.MaxLevel = 50;
    out.AttenStep = 2;
    out.AttenFixed = 60;
    out.AttenStart = 90; 

    out.DAlevel = 5;
    out.MicGainL_dB = 30;
    out.MicGainR_dB = 30;
    out.frfileL = [];
    out.frfileR = [];

    out.OutChanL = 1;
    out.OutChanR = 2;
    out.InChanL = 128;
    out.InChanR = 129;
	out.ISI = 100;
    return;

    otherwise
	disp([mfilename ': unknown information type ' stype '...']);
    out = [];
	return;
 
end    
    
