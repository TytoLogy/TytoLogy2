% indev frequency (Hz) = 48828.125
% outdev frequency (Hz) = 195312.5

%% configure structs

%config = FOCHS_config('RZ6OUT200K_RZ5DIN');
% lock file
config.TDTLOCKFILE = fullfile(pwd, 'tdtlockfile.mat');
config.CONFIGNAME = 'RZ6OUT200K_RZ5DIN';
% function handles
config.ioFunc = @FOCHS_RZ6RZ5Dio;
config.TDTsetFunc = @FOCHS_RZ6RZ5Dsettings;
config.setattenFunc = @RZ6setatten;
% input device
config.indev.hardware = 'RZ5D';
config.indev.Fs = 50000;
config.indev.Circuit_Path = 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ5D';
config.indev.Circuit_Name = 'RZ5D_50k_4In_1Out_zBus';
config.indev.Dnum = 1; % device number
% output device
config.outdev.hardware = 'RZ6';
config.outdev.Fs = 200000;
config.outdev.Circuit_Path = 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ6'; 
config.outdev.Circuit_Name = 'RZ6_2ChannelOutputAtten_zBus.rcx';
config.outdev.Dnum = 1; % device number


% -- TDT parameters
% tdt = FOCHS_init('TDT:PARAMS');
tdt.AcqDuration = 1000;
tdt.SweepPeriod = tdt.AcqDuration + 10;
tdt.TTLPulseDur = 1;
tdt.CircuitGain = 20000;      % gain for TDT circuit
tdt.MonitorGain = 20000;
tdt.HPEnable = 1;         % enable high pass filter
tdt.HPFreq = 100;         % high pass frequency
tdt.LPEnable = 1;         % enable low pass filter
tdt.LPFreq = 10000;       % low pass frequency


% -- animal info
%animal = FOCHS_init('ANIMAL');
animal.Animal = '000';
animal.Unit = '0';
animal.Rec = '0';
animal.Date = TytoLogy_datetime('date');
animal.Time = TytoLogy_datetime('time');
animal.Pen = '0';
animal.AP = '0';
animal.ML = '0';
animal.Depth = '0';
animal.comments = '';

% stimulus = FOCHS_init('STIMULUS:PARAMS');
stimulus.ISI = 500;
stimulus.Duration = 100;
stimulus.Delay = 100;
stimulus.Ramp = 5;
stimulus.RadVary = 0;
stimulus.Frozen = 0;

% tone stimulus
tone.frequency = 5000;
tone.amplitude = 1;

% -- TDT I/O channels ---- default TDT hardware = 'NO_TDT'
% channels = FOCHS_init('CHANNELS:RZ6_RZ5D');
channels.OutputChannelL = 1;
channels.OutputChannelR = 2;
channels.InputChannel1 = 1;
channels.InputChannel2 = 2;
channels.InputChannel3 = 3;
channels.InputChannel4 = 4;
channels.OpticalChannel = 10;
channels.MonitorChannel = 1;
channels.MonitorOutputChannel = 9; 

% -- parameters for optical stimulus
% optical = FOCHS_init('OPTICAL');
optical.Enable = 0;
optical.Amp = 0;
optical.Dur = 5;
optical.Delay = 0;
optical.Channel = 10;	% note that this is also set in RZ6+RZ5D

%% start TDT hardware
try
	[outhandles, outflag] = FOCHS_TDTopen(config);
catch ME
	error('Cannot open TDT hardware');
end
indev = outhandles.indev;
outdev = outhandles.outdev;
zBUS = outhandles.zBUS;
PA5L = outhandles.PA5L;
PA5R = outhandles.PA5R;

%% settings
Fs = FOCHS_RZ6RZ5Dsettings(indev, outdev, tdt, stimulus, channels, optical);


%% do stuff

stim = synmonosine(stimulus.Duration, outdev.Fs, tone.frequency, tone.amplitude, 0);
nullstim = syn_null(stimulus.Duration, outdev.Fs, 0);

S = [stim; nullstim];

inpts = ms2bin(tdt.AcqDuration, indev.Fs);


RPsettag(outdev, 'AttenL', 0);

if indev.status && outdev.status && zBUS.status
[resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4, out_msg] = ...
    FOCHS_RZ6RZ5Dio(S, inpts, indev, outdev, zBUS);
else
	error('stati == 0');
end

figure(5)
subplot(411), plot(resp1);
subplot(412), plot(resp2);
subplot(413), plot(resp3);
subplot(414), plot(resp4);


%% stop TDT hardware
[outhandles, outflag] = FOCHS_TDTclose(config, indev, outdev, zBUS, PA5L, PA5R);
indev = outhandles.indev;
outdev = outhandles.outdev;
zBUS = outhandles.zBUS;
PA5L = outhandles.PA5L;
PA5R = outhandles.PA5R;



