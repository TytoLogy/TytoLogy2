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
% Original Version Written (MicrophoneCal): 2008-2010 by SJS
% Upgraded Version Written (MicrophoneCal2_init): 2011-2012 by GA
%------------------------------------------------------------------------

stype = upper(stype);

switch stype

    case 'INIT'
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

        out.ISI = 100; 
        out.Duration = 150;
        out.Delay = 10;
        out.Ramp = 5;

        out.AcqDuration = 200;
        out.SweepPeriod = out.AcqDuration + 10;
        out.TTLPulseDur = 1;
        out.HPFreq = 100;
        out.LPFreq = 16000;

        out.SaveRawData = 0; 
        return;

    case 'NO_TDT'  % default = No_TDT
        disp('No_TDT selected');
        out.CONFIGNAME = stype;
        out.OutChannel = 0;
        out.RefChannel = 0;
        out.MicChannel = 0;

        out.Circuit_Path = [];
        out.Circuit_Name = [];
        out.Dnum = 0; % device number

        out.RXinitFunc = @(varargin) struct('C',0,'handle',0,'status',-1);
        out.PA5initFunc = @(varargin) struct('C',0,'handle',0,'status',-1);
        out.RPloadFunc = @(varargin) -1;
        out.RPrunFunc = @(varargin) -1;
        out.RPcheckstatusFunc = @(varargin) -1;
        out.RPsamplefreqFunc = @(varargin) 50000;
        out.TDTsetFunc = @MicrophoneCal2_NoTDT_settings;
        out.setattenFunc = @(varargin) -1;
        out.ioFunc = @MicrophoneCal2_NoTDT_calibration_io;
        out.PA5closeFunc = @(varargin) -1;
        out.RPcloseFunc = @(varargin) -1;
        return;    
    
	case 'RX8_50K'	 % for RX8
        disp('RX8_50K selected');
        out.CONFIGNAME = stype;
        out.OutChannel = 17;
        out.RefChannel = 1;
        out.MicChannel = 2;

        out.Circuit_Path = 'C:\TytoLogy2\toolbox2\TDTcircuits\';
%        out.Circuit_Name = 'RX8_3_TwoChannelInOut';
%        out.Dnum = 1; % device number
        out.Circuit_Name = 'RX8_2_TwoChannelInOut'; % for Pena Lab
        out.Dnum = 2; % device number % for Pena Lab

        out.RXinitFunc = @RX8init;
        out.PA5initFunc = @PA5init;
        out.RPloadFunc = @RPload2;
        out.RPrunFunc = @RPrun;
        out.RPcheckstatusFunc = @RPcheckstatus;
        out.RPsamplefreqFunc = @RPsamplefreq;
        out.TDTsetFunc = @MicrophoneCal2_TDT_settings;
        out.setattenFunc = @PA5setatten;
        out.ioFunc = @hp2_calibration_io;
        out.PA5closeFunc = @PA5close;
        out.RPcloseFunc = @RPclose;
        return;
    
	case 'RX6_50K'	 % for RX6
        disp('RX6_50K selected');
        out.CONFIGNAME = stype;
        out.OutChannel = 1;
        out.RefChannel = 128;
        out.MicChannel = 129;

        out.Circuit_Path = 'C:\TytoLogy2\toolbox2\TDTcircuits\';
        out.Circuit_Name = 'RX6_50k_TwoChannelInOut';
        out.Dnum = 1; % device number

        out.RXinitFunc = @RX6init2;
        out.PA5initFunc = @PA5init;
        out.RPloadFunc = @RPload2;
        out.RPrunFunc = @RPrun;
        out.RPcheckstatusFunc = @RPcheckstatus;
        out.RPsamplefreqFunc = @RPsamplefreq;
        out.TDTsetFunc = @MicrophoneCal2_TDT_settings;
        out.setattenFunc = @PA5setatten;
        out.ioFunc = @hp2_calibration_io;
        out.PA5closeFunc = @PA5close;
        out.RPcloseFunc = @RPclose;
        return;

    otherwise
    	disp([mfilename ': unknown parameter ' stype '...']);
        out = [];
    	return;
 
end    
    
