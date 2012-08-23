%--------------------------------------------------------------------------
% MicrophoneCal2_Run.m
%--------------------------------------------------------------------------
%  Script that runs the calibration protocol
%    This script is called by MicrophoneCal2.m
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Original Versions Written (MicrophoneCal_RunCalibration, 
%    MicrophoneCal_settings, MicrophoneCal_tdtinit, 
%    MicrophoneCal_frdata_init, MicrophoneCal_tdtexit): 2008-2010 by SJS
% Upgraded Version Created (MicrophoneCal2_Run): 2011-2012 by GA
%------------------------------------------------------------------------
% Notes (Apr 2012, GA)
%  Function handles are stored under the config structure and 
%  defined in MicrophoneCal2_init.m
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display message
str = 'Initial setup for calibration'; 
set(handles.textMessage, 'String', str);
% general constants
REF = 1; 
MIC = 2;
MAX_ATTEN = 120;
CLIPVAL = 10; 	% clipping value
% making a local copy of the cal settings structure
cal = handles.h2.cal;
% I/O channels
cal.OutChannel = handles.h2.config.OutChannel;
cal.RefChannel = handles.h2.config.RefChannel;
cal.MicChannel = handles.h2.config.MicChannel;
% Calibration Settings
cal.bkdata = handles.h2.bkdata; % BK correction factor
cal.VtoPa = cal.RefMicSens^-1;  % Volts to Pascal factor
cal.RefGain = 10^(cal.RefGain_dB/20); % ref gain factor
cal.MicGain = 10^(cal.MicGain_dB/20); % mic gain factor
% Frequencies
cal.F = [cal.Fmin cal.Fstep cal.Fmax];
cal.Freqs = cal.Fmin : cal.Fstep : cal.Fmax;
cal.Nfreqs = length(cal.Freqs);
% pre-compute the sinusoid RMS factor
cal.RMSsin = 1/sqrt(2);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the TDT devices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display message
str = 'Initializing TDT'; 
set(handles.textMessage, 'String', str);
% make a local copy of the TDT config settings structure
config = handles.h2.config; 
% make iodev structure
iodev.Circuit_Path = config.Circuit_Path;
iodev.Circuit_Name = config.Circuit_Name;
iodev.Dnum = config.Dnum; 
% initialize RX* 
tmpdev = config.RXinitFunc('GB', config.Dnum); 
iodev.C = tmpdev.C;
iodev.handle = tmpdev.handle;
iodev.status = tmpdev.status;
% initialize PA5 attenuators (left = 1 and right = 2)
PA5L = config.PA5initFunc('GB', 1);
PA5R = config.PA5initFunc('GB', 2);
% load circuit
iodev.rploadstatus = config.RPloadFunc(iodev); 
% start circuit
config.RPrunFunc(iodev);
% check status
iodev.status = config.RPcheckstatusFunc(iodev);
% Query the sample rate from the circuit 
iodev.Fs = config.RPsamplefreqFunc(iodev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up TDT parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config.TDTsetFunc(iodev, cal); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup storage variables -- frdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frdata.version = '2.1';
frdata.time_str = datestr(now, 31);	% date and time
frdata.timestamp = now;				% timestamp
frdata.adFc = iodev.Fs;				% analog input rate 
frdata.daFc = iodev.Fs;				% analog output rate 
frdata.F = cal.F;					% freq range (matlab string)
frdata.Freqs = cal.Freqs;			% frequencies (matlab array)
frdata.Nfreqs = cal.Nfreqs;			% number of freqs to collect
frdata.Reps = cal.Reps;				% reps per frequency
frdata.cal = cal;                   % parameters for calibration session
frdata.Atten = cal.Atten;			% initial attenuator setting
frdata.max_spl = 0;					% maximum spl (will be determined in program)
frdata.min_spl = 0;					% minimum spl (will be determined in program)
frdata.DAlevel = cal.DAlevel;		% output peak voltage level

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up arrays to hold data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup cell for raw data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rawdata.Freqs = frdata.Freqs;
rawdata.background = cell(1, cal.Reps);
rawdata.resp = cell(cal.Nfreqs, cal.Reps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in the BK mic xfer function for pressure field and 
% get correction values for use with the free field mic
% If free-field, set correction factor to 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch cal.FieldType
    case 'PRESSURE'
		% interpolate to get values at desired freqs (data in dB)
		frdata.bkpressureadj = ...
            interp1(cal.bkdata.Response(:, 1), cal.bkdata.Response(:, 2), cal.Freqs);
		% convert to factor
		frdata.bkpressureadj = 1./invdb(frdata.bkpressureadj);
    case 'FREE'
        frdata.bkpressureadj = ones(size(cal.Freqs));
    otherwise 
        disp('unknown field type: MicrophoneCal2_Run');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the start and end bins for the calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_bin = ms2bin(cal.Delay + cal.Ramp, iodev.Fs);
if start_bin < 1
    start_bin = 1;
end
end_bin = start_bin + ms2bin(cal.Duration - 2*cal.Ramp, iodev.Fs);
zerostim = syn_null(cal.Duration, iodev.Fs, 1);  % make zeros for both channels
outpts = length(zerostim);
acqpts = ms2bin(cal.AcqDuration, iodev.Fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up vectors for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dt = 1/iodev.Fs;
tvec = 1000*dt*(0:(acqpts-1));
stimvec = 0*tvec; 
delay_bin = ms2bin(cal.Delay, iodev.Fs);
duration_bin = ms2bin(cal.Duration, iodev.Fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, get the background noise level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display message
str = 'Background Noise';
set(handles.textMessage, 'String', str);
% set max attenuation
config.setattenFunc(PA5L, MAX_ATTEN);
config.setattenFunc(PA5R, MAX_ATTEN);
% pause to let things settle down
pause(1);

% plot the zero stim array
axes(handles.axesStim);
plot(tvec, stimvec, 'b');

% record background 
for rep = 1:cal.Reps
    % update freq info box
	update_ui_str(handles.editFreqVal, 'Backgnd');
    % play the "sound"
	[resp, rate] = config.ioFunc(iodev, zerostim, acqpts);
	% plot responses
    axes(handles.axesRef);
	plot(tvec, resp{REF}, '-k');
    axes(handles.axesMic);
	plot(tvec, resp{MIC}, '-g');
    % compute dB SPL from the REF mic response
    background{REF}(rep) = rms(resp{REF}) / cal.RefGain;
    update_ui_str(handles.editRefVal, sprintf('%.2f', background{REF}(rep)));
	background{REF}(rep) = dbspl(cal.VtoPa * background{REF}(rep));
	update_ui_str(handles.editRefSPL, sprintf('%.2f', background{REF}(rep)));    
    % determine the magnitude of the MIC response
    background{MIC}(rep) = rms(resp{MIC}) / cal.MicGain;
    update_ui_str(handles.editMicVal, sprintf('%.2f', background{MIC}(rep)));
    % store the response data
	rawdata.background{rep} = cell2mat(resp');
	pause(cal.ISI/1000);
end

% store data to background array
frdata.background(REF, 1) = mean( background{REF} );
frdata.background(REF, 2) = std( background{REF} );
frdata.background(MIC, 1) = mean( background{MIC} );
frdata.background(MIC, 2) = std( background{MIC} );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now initiate sweeps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display message
str = 'Now Running Calibration';
set(handles.textMessage, 'String', str);
% set max attenuation
config.setattenFunc(PA5L, cal.Atten); % this is the speaker channel
config.setattenFunc(PA5R, MAX_ATTEN); % this is unused so max the atten
% pause to let things settle down
pause(1);

% now starting
STOPFLAG = 0;	
rep = 1;
freq_index = 1;
tic % timer start

% ****** main LOOP through the frequencies ******
while ~STOPFLAG && ( freq_index <= cal.Nfreqs )

    % get the current frequency
    freq = cal.Freqs(freq_index); 
    % tell user what frequency is being played
    update_ui_str(handles.editFreqVal, freq);  
	% synthesize and scale the sine wave (monaural)	
	[S, stimspec.RMS, stimspec.phi] = ...
        syn_calibrationtone(cal.Duration, iodev.Fs, freq, 0, 'L');
	S = cal.DAlevel*S;
	% apply the sin^2 amplitude envelope 
	S = sin2array(S, cal.Ramp, iodev.Fs);
	% plot the stim array
    stimvec = 0 * tvec; % reset to zero
    stimvec(delay_bin+1 : delay_bin+duration_bin) = S(1, :); % copy stim data
	axes(handles.axesStim);
	plot(tvec, stimvec, 'b');

	% now, collect the data for frequency FREQ
	for rep = 1:cal.Reps
		% play the sound;
		[resp, rate] = config.ioFunc(iodev, S, acqpts); 
        % plot the response
		axes(handles.axesRef);	
        plot(tvec, resp{REF}, '-k');
		axes(handles.axesMic);	
        plot(tvec, resp{MIC}, '-g');
        % determine the magnitude and phase of the response
        [refmag, refphi] = fitsinvec(resp{REF}(start_bin:end_bin), 1, iodev.Fs, freq);
        [micmag, micphi] = fitsinvec(resp{MIC}(start_bin:end_bin), 1, iodev.Fs, freq);
        [refdistmag, refdistphi] = fitsinvec(resp{REF}(start_bin:end_bin), 1, iodev.Fs, 2*freq);	
        [micdistmag, micdistphi] = fitsinvec(resp{MIC}(start_bin:end_bin), 1, iodev.Fs, 2*freq);				
		% compute 2nd harmonic distortion ratio
		tmpdists{REF}(freq_index, rep) = refdistmag / refmag;
		tmpdists{MIC}(freq_index, rep) = micdistmag / micmag;
		% adjust for the gain of the preamp and convert to RMS
    	refmag = cal.RMSsin * refmag * frdata.bkpressureadj(freq_index) / cal.RefGain;
		micmag = cal.RMSsin * micmag / cal.MicGain;
		% store the data in arrays
		tmpmags{REF}(freq_index, rep) = refmag;
		tmpmags{MIC}(freq_index, rep) = micmag;
		tmpphis{REF}(freq_index, rep) = refphi;
		tmpphis{MIC}(freq_index, rep) = micphi;
		% Check for possible clipping (values > 10V for TDT System 3)
		if max(resp{REF}) >= CLIPVAL
			STOPFLAG = REF;
        elseif max(resp{MIC}) >= CLIPVAL
            STOPFLAG = MIC;
        end
        % show calculated values
    	update_ui_str(handles.editRefVal, sprintf('%.2f', 1000*refmag));
    	update_ui_str(handles.editRefSPL, sprintf('%.2f', dbspl(cal.VtoPa*refmag)));
    	update_ui_str(handles.editMicVal, sprintf('%.2f', 1000*micmag));
		% store the raw response data
		rawdata.resp{freq_index, rep} = cell2mat(resp');
        % pause
		pause(cal.ISI/1000);
    end

    % compute the averages for this frequency
    frdata.mag(REF, freq_index) = mean( tmpmags{REF}(freq_index, :) );
    frdata.mag_stderr(REF, freq_index) = std( tmpmags{REF}(freq_index, :) );
    frdata.phase(REF, freq_index) = mean( unwrap(tmpphis{REF}(freq_index, :)) );
    frdata.phase_stderr(REF, freq_index) = std( unwrap(tmpphis{REF}(freq_index, :)) );
    frdata.dist(REF, freq_index) = mean( tmpdists{REF}(freq_index, :) );
    
    frdata.mag(MIC, freq_index) = mean( tmpmags{MIC}(freq_index, :) );
    frdata.mag_stderr(MIC, freq_index) = std( tmpmags{MIC}(freq_index, :) );
    frdata.phase(MIC, freq_index) = mean( unwrap(tmpphis{MIC}(freq_index, :)) );
    frdata.phase_stderr(MIC, freq_index) = std( unwrap(tmpphis{MIC}(freq_index, :)) );
    frdata.dist(MIC, freq_index) = mean( tmpdists{MIC}(freq_index, :) );

	% increment frequency index counter
	freq_index = freq_index + 1;

	% check if STOP_FLG is set
	if STOPFLAG
        str = 'STOPFLAG detected';
        set(handles.textMessage, 'String', str);
    	errstr = sprintf('Possible clip on channel %d', STOPFLAG);
        errordlg(errstr, 'Clip alert!');
		break;
    end
    % check if user pressed ABORT button 
	if read_ui_val(handles.buttonAbort) == 1
        str = 'ABORTING Calibration';
        set(handles.textMessage, 'String', str);
        handles.h2.ABORT = 1;
        guidata(hObject, handles);    
		break;
    end

end %****** end of cal loop
cal.timer = toc; % get the time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% exit gracefully 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config.PA5closeFunc(PA5L);
config.PA5closeFunc(PA5R);
config.RPcloseFunc(iodev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if we made it to the end of the frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if freq >= cal.Freqs(end) && ~handles.h2.ABORT % if yes, set the COMPLETE flag
	handles.h2.COMPLETE = 1;
    guidata(hObject, handles);
else % if not, skip the calculations and return
	handles.h2.COMPLETE = 0;
	handles.h2.frdata = frdata;
	handles.h2.rawdata = rawdata;
    guidata(hObject, handles);	
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data are complete, do some computations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute magnitude correction
% 	magnitude adj = knowles mic Vrms / Ref mic Vrms
frdata.adjmag = frdata.mag(MIC, :) ./ frdata.mag(REF, :);	
% compute phase correction
% 	phase adj = Knowles mic deg - ref mic degrees
frdata.adjphi = frdata.phase(MIC, :) - frdata.phase(REF, :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data to file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fname, fpath] = uiputfile('*_fr2.mat', 'Save FR Data');
if handles.h2.cal.SaveRawData
    save('temp_fr2.mat', 'frdata', 'rawdata', '-mat');
    if fname
    	save(fullfile(fpath, fname), 'frdata', 'rawdata', '-mat');
    end
else 
    save('temp_fr2.mat', 'frdata', '-mat');
    if fname
    	save(fullfile(fpath, fname), 'frdata', '-mat');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save handles and data and temp file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.h2.frdata = frdata;
handles.h2.rawdata = rawdata;
guidata(hObject, handles);

