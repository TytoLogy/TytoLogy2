function out = MicrophoneCal2_init(stype)
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
% Originally Written (MicrophoneCal): 2008-2010 by SJS
% Renamed Version Created (MicrophoneCal2_init): November, 2011 by GA
%
% Revisions: modified version for MicrophoneCal2
% 
%------------------------------------------------------------------------

stype = upper(stype);

switch stype
    case 'INIT'  %%% edit the line below to get desired settings
%    out = 'RX8:DEFAULT';
    out = 'RX6:DEFAULT';
    return;
    
	case 'RX8:DEFAULT'	 % for RX8
    disp('RX8:DEFAULT selected');
    out.Fmin = 200;
    out.Fmax = 15000;
    out.Fstep = 100;
    out.Reps = 5;
    out.Atten = 40; 

    out.DAlevel = 5;
    out.RefMicSens = 0.01;
    out.RefGain_dB = 0;
    out.MicGain_dB = 40;
    out.FieldType = 'PRESSURE';
    %out.FieldType = 'FREE';

    out.OutChannel = 17;
    out.RefChannel = 1;
    out.MicChannel = 2;
    return;
    
	case 'RX6:DEFAULT'	 % for RX6
    out.Fmin = 200;
    out.Fmax = 15000;
    out.Fstep = 100;
    out.Reps = 5;
    out.Atten = 40; 

    out.DAlevel = 5;
    out.RefMicSens = 0.01;
    out.RefGain_dB = 0;
    out.MicGain_dB = 30;
    out.FieldType = 'PRESSURE';
    %out.FieldType = 'FREE';

    out.OutChannel = 1;
    out.RefChannel = 128;
    out.MicChannel = 129;
    return;

    otherwise
	disp([mfilename ': unknown information type ' stype '...']);
    out = [];
	return;
 
end    
    
