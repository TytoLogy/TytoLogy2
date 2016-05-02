function out = HPSearch2c_init(stype)
%------------------------------------------------------------------------
% out = HPSearch2c_init(stype)
%------------------------------------------------------------------------
% 
% Sets initial values, limits, initialization, etc. etc.
%
%------------------------------------------------------------------------
% Input Arguments:
%     stype        string
%
% Output Arguments:
%     out         struct containing settings for requested type
% 
%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch_init): 2009-2010 by SJS
% Upgraded Version Written (HPSearch2_init): 2011-2012 by GA
% Adopted for HPSearch2a (HPSearch2a_init): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_init): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_init): Jan 2015 by GA 
%  - added code for external stimulus 
%------------------------------------------------------------------------

%----------------------------------------------------------------------
% check input argument
%----------------------------------------------------------------------
if ~nargin
    stype = 'default';
end
stype = upper(stype);

%----------------------------------------------------------------------
% return desired information
%----------------------------------------------------------------------
switch stype

%% earphone calibration information
    case 'CALINFO'
        out.fpathL = [];
        out.fnameL = [];
        out.loadedL = 0;
        out.FmaxL = 100000;
        out.FminL = 0;
        out.fpathR = [];
        out.fnameR = [];
        out.loadedR = 0;
        out.FmaxR = 100000;
        out.FminR = 0;
        return;

%% animal information
    case 'ANIMAL'
        out.Animal = '000';
        out.Unit = '0';
        out.Rec = '0';
        out.Date = TytoLogy2_datetime('date');
        out.Time = TytoLogy2_datetime('time');
        out.Pen = '0';
        out.AP = '0';
        out.ML = '0';
        out.Depth = '0';
        out.comments = '';
        return;

%% parameters for search controls
    case 'SEARCH:PARAMS'
        out.stimtype = 'NOISE';
        out.LeftON = 0;
        out.RightON = 0;
        out.ITD = 0;
        out.ILD = 0;
        out.Latt = 120;
        out.Ratt = 120;
        out.ABI = 50;
        out.BC = 100;
        out.Freq = 5000;
        out.BW = 8000;
        out.Fmax = floor(out.Freq + out.BW/2);
        out.Fmin = ceil(out.Freq - out.BW/2);
        out.sAMp = 0;
        out.sAMf = 0;
        return;

%% search parameter limits
    case 'SEARCH:LIMITS' 
        out.ITD = [-2000 2000];
        out.ILD = [-50 50];
        out.Latt = [0 120];
        out.Ratt = [0 120];
        out.ABI = [0 100];
        out.BC = [-100 100];
        out.Freq = [100 12000];
        out.defaultFreq = out.Freq;
        out.BW = [0 10000];
        out.sAMp = [0 100];
        out.sAMf = [0 1000];
        return;

%% stimulus settings
    case 'STIMULUS:PARAMS'
        out.ISI = 200;
        out.Duration = 100;
        out.Delay = 50;
        out.Ramp = 5;
        out.RadVary = 0;
        out.Frozen = 0;
        return;

%% stimulus setting limits
    case 'STIMULUS:LIMITS'
        out.ISI = [0 5000];
        out.Duration = [1 3000];
        out.Delay = [0 1500];        
        out.Ramp = [0 30];
        out.Reps = [1 500];
        return;

%% TDT settings
    case 'TDT:PARAMS' 
        out.AcqDuration = 200;
        out.SweepPeriod = out.AcqDuration + 10;
        out.TTLPulseDur = 1;
%        out.CircuitGain = 1;          % gain for TDT circuit
        out.HPEnable = 1;             % enable high pass filter
        out.HPFreq = 100;             % high pass frequency
        out.LPEnable = 1;             % enable low pass filter
        out.LPFreq = 12000;           % low pass frequency
        out.MonitorGain = 1000;       % monitor gain for medusa 
        return;        

%% TDT setting limits
    case 'TDT:LIMITS'
        out.AcqDuration = [1 3000];
        out.TTLPulseDur = [1 100];
%        out.CircuitGain = [0 100000];
        out.HPFreq = [0.001 20000];
        out.LPFreq = [100 25000];
        out.MonitorGain = [0 100000];
        return;

%% I/O channel settings (depending on TDT hardware type)
    case 'CHANNELS:NO_TDT' 
        out.InputChannel = 0;
        out.OutputChannelL = 0;
        out.OutputChannelR = 0;
        return;        
    case 'CHANNELS:RX8_50K' 
        out.InputChannel = 1;
        out.OutputChannelL = 17;
        out.OutputChannelR = 18;
        return;        
    case 'CHANNELS:RX6_50K' 
        out.InputChannel = 128;
        out.OutputChannelL = 1;
        out.OutputChannelR = 2;
        return;        

%% spike analysis settings
    case 'ANALYSIS:PARAMS'
        out.WindowWidth = 0.2;
        out.StartTime = 50;
        out.EndTime = 150;
        out.ThresSD = 5;
        out.Raster = 30;
        out.Threshold = 5.0; % manual threshold
        out.Yaxis = 10.0; % manual Y-axis
        out.Scale = 0.1; 
        out.Sign = 1.0;
        out.Peak = 0;
        out.ThAuto = 1;
        out.YAuto = 1;
        return;

%% spike analysis setting limits
    case 'ANALYSIS:LIMITS'
        out.WindowWidth = [0 3000];
        out.StartTime = [0 3000];
        out.EndTime = [0 3000];
        out.ThresSD = [-100 100];
        out.Raster = [1 70];
        out.Threshold = [0.5 20.5];
        out.Yaxis = [0.5 20.5];
        return;

%% plot settings
    case 'PLOTS'
        out.plotResp = 1;
        out.plotRaster = 1;
        out.plotCurve = 1;
        out.plotUpclose = 1;
        out.plotPSTH = 1;
        out.plotISIH = 1;
        return;

%% stimulus types for CURVE
    case 'CURVE:TYPE'
        out.stimtype = 'TONE';
        out.side = 'BOTH';
        out.Spont = 1;
        out.Temp = 0;
        out.SaveStim = 0;
        return;

%% parameters for CURVE
    case 'CURVE:BF'
        out.curvetype = 'BF';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '50';
        out.Freqstring = '1000:500:8000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
    case 'CURVE:ITD'
        out.curvetype = 'ITD';
        out.Reps = 5;
        out.ITDstring = '-300:30:300';
        out.ILDstring = '0';
        out.ABIstring = '50';
        out.Freqstring = '4000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;

    case 'CURVE:ILD'
        out.curvetype = 'ILD';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '-20:2:20';
        out.ABIstring = '50';
        out.Freqstring = '4000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
    case 'CURVE:ABI'
        out.curvetype = 'ABI';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '0:5:60';
        out.Freqstring = '4000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
    case 'CURVE:BC'
        out.curvetype = 'BC';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '0';
        out.Freqstring = '[1000 9000]';
        out.BCstring = '0:10:100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
    case 'CURVE:FILDL'
        out.curvetype = 'FILDL';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '-20:2:20';
        out.ABIstring = '50';
        out.Freqstring = '4000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;

    case 'CURVE:FILDR'
        out.curvetype = 'FILDR';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '-20:2:20';
        out.ABIstring = '50';
        out.Freqstring = '4000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
	case 'CURVE:BEAT'
        out.curvetype = 'BEAT';
        out.Reps = 10;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '50';
        out.Freqstring = '[4000,4010]';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;

    case 'CURVE:SAMP'
        out.curvetype = 'SAMP';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '0';
        out.Freqstring = '[1000 9000]';
        out.BCstring = '0';
        out.sAMpstring = '0:10:100';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
    case 'CURVE:SAMF'
        out.curvetype = 'SAMF';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '0';
        out.Freqstring = '[1000 9000]';
        out.BCstring = '0';
        out.sAMpstring = '100';
        out.sAMfstring = '20:20:200';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;

    case 'CURVE:CF'
        out.curvetype = 'CF';
        out.Reps = 5;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '10:5:60';
        out.Freqstring = '1000:500:8000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;
        
    case 'CURVE:CD'
        out.curvetype = 'CD';
        out.Reps = 5;
        out.ITDstring = '-300:30:300';
        out.ILDstring = '0';
        out.ABIstring = '50';
        out.Freqstring = '3000:200:5000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;

    case 'CURVE:PH'
        out.curvetype = 'PH';
        out.Reps = 100;
        out.ITDstring = '0';
        out.ILDstring = '0';
        out.ABIstring = '50';
        out.Freqstring = '4000';
        out.BCstring = '100';
        out.sAMpstring = '0';
        out.sAMfstring = '0';
        out.ITD = eval(out.ITDstring);
        out.ILD = eval(out.ILDstring);
        out.ABI = eval(out.ABIstring);
        out.Freq = eval(out.Freqstring);
        out.BC = eval(out.BCstring);
        out.sAMp = eval(out.sAMpstring);
        out.sAMf = eval(out.sAMfstring);
        return;

%% parameters for CLICK
    case 'CLICK:PARAMS'
        out.clicktype = 'COND';
        out.side = 'BOTH';
        out.Samples = 2;
        out.Reps = 128;
        out.ITDstring = '0';
        out.ITD = eval(out.ITDstring);
        out.Latten = 0;
        out.Ratten = 0;
        return;

%% parameter limits for CLICK
    case 'CLICK:LIMITS'
        out.Samples = [2 10000];
        out.Reps = [1 2400];
        out.ITD = [-1000 1000];
        out.Latten = [0 120];
        out.Ratten = [0 120];
        return;

%% parameters for EXTSTIM --- added Jan 2015 by GA
    case 'EXTSTIM:PARAMS'
        out.cal = 'USE';
        out.side = 'BOTH';
        out.Reps = 10;
        out.ITDstring = '0';
        out.ITD = eval(out.ITDstring);
        out.Latten = 0;
        out.Ratten = 0;
        return;

%% parameter limits for EXTSTIM --- added Jan 2015 by GA 
    case 'EXTSTIM:LIMITS'
        out.Reps = [1 2400];
        out.ITD = [-1000 1000];
        out.Latten = [0 120];
        out.Ratten = [0 120];
        return;
%% parameter limits for EXTSTIM --- added Jan 2015 by FD 
    case 'EXTSTIM:FILEINFO'
        out.loaded = false;
        out.sample_len = []; % nr of samples after resampling
        out.nchan = []; % nr of channels
        out.stim_data = [];
        out.rms = [];
        return;

%% DATAVERSION is version code for output binary file data 
    case 'DATAVERSION'
        out = 2.2;
        return;

%% if the argument is not known...
    otherwise
        disp([mfilename ': unknown information type ' stype '...']);
        out = [];
        return;
end
