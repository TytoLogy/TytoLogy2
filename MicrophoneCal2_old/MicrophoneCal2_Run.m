%--------------------------------------------------------------------------
% MicrophoneCal2_Run.m
%--------------------------------------------------------------------------
%  Script that runs the calibration protocol
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Originally Written (MicrophoneCal_RunCalibration): 2008-2010 by SJS
% Renamed Version Created (MicrophoneCal2_Run): November, 2011 by GA
%
% Revisions: modified version for MicrophoneCal2
% 
%------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% making a local copy of the cal settings structure
cal = handles.h2.cal;
% loading settings and constants 
MicrophoneCal2_Run_settings;
% starting the TDT circuit
MicrophoneCal2_Run_tdtinit;
handles.iodev = iodev;
% setup storage variables
MicrophoneCal2_Run_frdata_init;
% save handles structure
guidata(hObject, handles);		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in the BK mic xfer function for pressure field and 
% get correction values for use with the free field mic
% If free-field, set correction factor to 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
switch cal.FieldType
    case 'PRESSURE'
		% interpolate to get values at desired freqs (data in dB)
		frdata.bkpressureadj = ...
            interp1(cal.bkdata.Response(:, 1), cal.bkdata.Response(:, 2), cal.Freqs);
		% convert to factor
		frdata.bkpressureadj = 1./invdb(frdata.bkpressureadj);
    case 'FREE'
        frdata.bkpressureadj = ones(size(Freqs));
    otherwise 
        disp('unknown field type: MicrophoneCal2_Run');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the start and end bins for the calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_bin = ms2bin(cal.Delay + cal.Ramp, iodev.Fs);
if ~start_bin
	start_bin = 1;
end
end_bin = start_bin + ms2bin(cal.Duration - 2*cal.Ramp, iodev.Fs);
zerostim = syn_null(cal.Duration, iodev.Fs, 1);  % make zeros for both channels
outpts = length(zerostim);
acqpts = ms2bin(cal.AcqDuration, iodev.Fs);
% time vector for plots
dt = 1/iodev.Fs;
tvec = 1000*dt*(0:(acqpts-1));
%stim_start = ms2bin(cal.Delay, iodev.Fs);
%stim_end = stim_start + outpts - 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, get the background noise level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the zero array
axes(handles.axesStim);
plot(zerostim(1, :), 'b');
% set max attenuation
PA5setatten(PA5L, MAX_ATTEN);
PA5setatten(PA5R, MAX_ATTEN);
% pause to let things settle down
disp([mfilename ': collecting background data']);
pause(1);
% record background 
for rep = 1:cal.Reps
	update_ui_str(handles.editFreqVal, 'Backgnd');
    % play the "sound"
	[resp, rate] = hp2_calibration_io(iodev, zerostim, acqpts);
	% plot responses
    axes(handles.axesRef);
	plot(tvec,resp{REF}, '-k');
    axes(handles.axesMic);
	plot(tvec,resp{MIC}, '-g');
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
% set attenuators
PA5setatten(PA5L, cal.Atten);	% this is the speaker channel
PA5setatten(PA5R, MAX_ATTEN);	% this is unused so max the atten
% PAUSE	
pause(1)
disp([mfilename ': now running calibration...']);
% starting
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
	[Stmp, stimspec.RMS, stimspec.phi] = ...
        syn_calibrationtone(cal.Duration, iodev.Fs, freq, 0, 'MONO');
    S(1,:) = Stmp;
    S(2,:) = zeros(size(Stmp));
	S = cal.DAlevel*S;
	% apply the sin^2 amplitude envelope 
	S = sin2array(S, cal.Ramp, iodev.Fs);
	% plot the stim array
	axes(handles.axesStim);
	plot(S(1, :), 'b');

	% now, collect the data for frequency FREQ
	for rep = 1:cal.Reps
		% play the sound;
		[resp, rate] = hp2_calibration_io(iodev, S, acqpts); 
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
		% Check for possible clipping (values > 10V for TDT SysIII)
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
	% check if user pressed ABORT button or if STOP_FLG is set
	if STOPFLAG
		disp('STOPFLAG detected')
		cal.timer = toc;
		break;
    end
	if read_ui_val(handles.buttonAbort) == 1
		disp('ABORTING Calibration')
		cal.timer = toc;
		break;
    end

end %****** end of cal loop
cal.timer = toc; % get the time

if STOPFLAG
	errstr = sprintf('Possible clip on channel %d', STOPFLAG);
	errordlg(errstr, 'Clip alert!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exit gracefully (close TDT objects, etc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MicrophoneCal2_Run_tdtexit;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if we made it to the end of the frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if freq == cal.F(3) % if yes, complete
	COMPLETE = 1;
else % if not, incomplete, skip the calculations and return
	COMPLETE = 0;
	handles.h2.frdata = frdata;
	handles.h2.rawdata = rawdata;
	return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data are complete, do some computations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute magnitude correction
% 	magnitude adj = knowles mic Vrms / Ref mic Vrms
frdata.adjmag = frdata.mag(MIC, :) ./ frdata.mag(REF, :);	
% compute phase correction
% 	phase adj = Knowles mic deg - ref mic degrees
frdata.adjphi = frdata.phase(MIC, :) - frdata.phase(REF, :);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save handles and data and temp file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.h2.frdata = frdata;
handles.h2.rawdata = rawdata;
handles.h2.cal = cal;
guidata(hObject, handles);

[fname, fpath] = uiputfile('*_fr2.mat', 'Save FR Data');
if fname
	save(fullfile(fpath, fname), 'frdata', 'cal', '-mat');
	save([datestr(now,'yyyy-mm-dd') '_fr2.mat'], 'frdata', 'cal', '-mat');
else
	save([datestr(now,'yyyy-mm-dd') '_fr2.mat'], 'frdata', 'cal', '-mat');
end

