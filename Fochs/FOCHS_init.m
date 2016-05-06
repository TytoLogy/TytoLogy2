function out = FOCHS_init(stype)
%------------------------------------------------------------------------
% out = FOCHS_init(stype)
%------------------------------------------------------------------------
% 
% Sets initial values, limits, initialization, etc. etc.
%
%------------------------------------------------------------------------
% Input Arguments:
% 	stype		string indicating desired parameters
% 			'CALINFO'		earphone calibration information
%			'ANIMAL'			animal information
% 
% Output Arguments:
% 	out         struct containing settings for requested type
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Go Ashida & Sharad Shanbhag
% ashida@umd.edu
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version (HPSearch): 2009-2011 by SJS
% Upgraded Version (HPSearch2): 2011-2012 by GA
% Four-channel Input Version (FOCHS): 2012 by GA
% Optogen mods: 2016 by SJS
%------------------------------------------------------------------------
% Revisions:
%	3 May 2016 (SJS):
%	 - added 'OPTICAL' information category
%	 - added 'OPTICAL:LIMITS' 
%------------------------------------------------------------------------

%----------------------------------------------------------------------
% check input argument
%----------------------------------------------------------------------
if ~nargin
    stype = '';
end

%----------------------------------------------------------------------
% return desired information
%----------------------------------------------------------------------
switch upper(stype)

	% optical stimulation information (defaults)
	case 'OPTICAL'
		out.Enable = 0;
		out.Amp = 0;
		out.Dur = 5;
		out.Delay = 0;
		out.Channel = 10;	% note that this is also set in RZ6+RZ5D
		return;
	
	case 'OPTICAL:LIMITS'
		out.Amp = [0 5000];
		out.Dur = [0 1000];
		out.Delay = [0 1000];
		out.Channel = [9 12];
		return;

	% earphone calibration information
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

	% animal information
	case 'ANIMAL'
		out.Animal = '000';
		out.Unit = '0';
		out.Rec = '0';
		out.Date = TytoLogy_datetime('date');
		out.Time = TytoLogy_datetime('time');
		out.Pen = '0';
		out.AP = '0';
		out.ML = '0';
		out.Depth = '0';
		out.comments = '';
		return;

	% parameters for search controls
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

	% search parameter limits
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

	% stimulus settings (defaults)
	case 'STIMULUS:PARAMS'
		out.ISI = 200;
		out.Duration = 100;
		out.Delay = 50;
		out.Ramp = 5;
		out.RadVary = 0;
		out.Frozen = 0;
		return;

	% stimulus setting limits
	case 'STIMULUS:LIMITS'
		out.ISI = [0 5000];
		out.Duration = [1 3000];
		out.Delay = [0 1500];        
		out.Ramp = [0 30];
		out.Reps = [1 500];
		out.Trials = [1 1000];
		return;

	% TDT settings (defaults)
	case 'TDT:PARAMS' 
		out.AcqDuration = 200;
		out.SweepPeriod = out.AcqDuration + 10;
		out.TTLPulseDur = 1;
		out.CircuitGain = 1;      % gain for TDT circuit
		out.MonitorGain = 1;
		out.HPEnable = 1;         % enable high pass filter
		out.HPFreq = 200;         % high pass frequency
		out.LPEnable = 1;         % enable low pass filter
		out.LPFreq = 12000;       % low pass frequency
		return;        

	% TDT setting limits
	case 'TDT:LIMITS'
		out.AcqDuration = [1 3000];
		out.TTLPulseDur = [1 100];
		out.CircuitGain = [0 100000];
		out.HPFreq = [0.001 20000];
		out.LPFreq = [100 25000];
		return;

	% I/O channel settings (depending on TDT hardware type)
	% 'CHANNELS:NO_TDT' is for testing with no TDT hardware
	case 'CHANNELS:NO_TDT' 
		out.OutputChannelL = 0;
		out.OutputChannelR = 0;
		out.InputChannel1 = 0;
		out.InputChannel2 = 0;
		out.InputChannel3 = 0;
		out.InputChannel4 = 0;
		return;
		
	% 'CHANNELS:RX8_50K' is for TDT RX8 module with 50kHz sampling rate
	case 'CHANNELS:RX8_50K' 
		out.OutputChannelL = 17;
		out.OutputChannelR = 18;
		out.InputChannel1 = 1;
		out.InputChannel2 = 2;
		out.InputChannel3 = 3;
		out.InputChannel4 = 4;
		return; 

	% 'CHANNELS:RZ6OUT200K_RZ5DIN' is for TDT RZ6 for audio out, RZ5D for spike in
	case 'CHANNELS:RZ6OUT200K_RZ5DIN' 
		out.OutputChannelL = 1;
		out.OutputChannelR = 2;
		out.InputChannel1 = 1;
		out.InputChannel2 = 2;
		out.InputChannel3 = 3;
		out.InputChannel4 = 4;
		out.OpticalChannel = 10;		% RZ5D DAC channel for optigen stimulus
		out.MonitorChannel = 1;			% electrode channel to send to audio monitor
		out.MonitorOutputChannel = 9;		% RZ5D DAC channel for audio monitor of spikes
		return; 

	% spike analysis settings (defaults)
	case 'ANALYSIS:PARAMS'
		out.StartTime = 50;
		out.EndTime = 150;
		return;

	% spike analysis setting limits
	case 'ANALYSIS:LIMITS'
		out.StartTime = [0 3000];
		out.EndTime = [0 3000];
		return;

	% plot settings (defaults)
	case 'PLOTS:DEFAULT'
		out.plotUpclose = 1;
		out.plotResp = 1;
		out.plotRaster = 1;
		out.Ch1 = 1;
		out.Ch2 = 1;
		out.Ch3 = 1;
		out.Ch4 = 1;
		return;

	% stimulus types for CURVE
	case 'CURVE:TYPE'
		out.stimtype = 'TONE';
		out.side = 'BOTH';
		out.Spont = 1;
		out.Temp = 0;
		out.SaveStim = 0;
		return;

	% parameters for CURVE
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

	% parameters for CLICK
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

	% parameter limits for CLICK
	case 'CLICK:LIMITS'
		out.Samples = [2 10000];
		out.Reps = [1 2400];
		out.ITD = [-1000 1000];
		out.Latten = [0 120];
		out.Ratten = [0 120];
		return;

	% DATAVERSION is version code for output binary file data (SJS)
	case 'DATAVERSION'
		out = 2.5;
		return;

	% if the argument is not known...
	otherwise
		errordlg([mfilename ': unknown information type ' stype '...']);
		out = [];
		return;
end
