%--------------------------------------------------------------------------
% HeadphoneCal2_Run.m
%--------------------------------------------------------------------------
%  Script that runs the calibration protocol
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Originally Written (HeadphoneCal_RunCalibration): 2008-2010 by SJS
% Renamed Version Created (HeadphoneCal2_Run): November, 2011 by GA
%
% Revisions: modified version for HeadphoneCal2
% 
%------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% making a local copy of the cal settings structure
cal = handles.h2.cal;
fr = handles.h2.fr;

% check if FR files are loaded
switch cal.Side 
    case 'BOTH' 
        if ~(fr.loadedR && fr.loadedL)
            disp('Load FR files (L and R) before calibration!');
            return;
        end
        cal.frL = fr.frdataL; 
        cal.frR = fr.frdataR; 
        cal.frfileL = fr.frfileL;
        cal.frfileR = fr.frfileR;

    case 'LEFT'
        if ~fr.loadedL
            disp('Load FR file (L) before calibration!');
            return;
        end
        cal.frL = fr.frdataL; 
        cal.frR = HeadphoneCal2_dummyFR; % dummy data struct for R
        cal.frfileL = fr.frfileL;
        cal.frfileR = [];
        
    case 'RIGHT'
        if ~fr.loadedR
            disp('Load FR file (R) before calibration!');
            return;
        end
        cal.frL = HeadphoneCal2_dummyFR; % dummy data struct for L
        cal.frR = fr.frdataR; 
        cal.frfileL = [];
        cal.frfileR = fr.frfileR;

end
handles.h2.cal = cal;
guidata(hObject, handles);

% loading settings and constants
HeadphoneCal2_Run_settings;

% Fetch the L and R headphone mic adjustment values for the 
% calibration frequencies using interpolation
cal.frL.magadjval = interp1(cal.frL.Freqs, cal.frL.adjmag, cal.Freqs);
cal.frR.magadjval = interp1(cal.frR.Freqs, cal.frR.adjmag, cal.Freqs);
cal.frL.phiadjval = interp1(cal.frL.Freqs, cal.frL.adjphi, cal.Freqs);
cal.frR.phiadjval = interp1(cal.frR.Freqs, cal.frR.adjphi, cal.Freqs);
handles.h2.cal = cal;
guidata(hObject, handles);

% check low freq limit
if cal.F(1) < max( cal.frL.F(1), cal.frR.F(1) )
	disp([mfilename ': requested LF calibration limit is out of FR file bounds']);
	return;
end
% check high freq limit
if cal.F(3) > min( cal.frL.F(3), cal.frR.F(3) )
	disp([mfilename ': requested HF calibration limit is out of FR file bounds']);
	return;
end

% starting the TDT circuit
HeadphoneCal2_Run_tdtinit;
handles.iodev = iodev;
guidata(hObject, handles);

% setup storage variables
HeadphoneCal2_Run_caldata_init;

% save handles structure
guidata(hObject, handles);

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
stim_start = ms2bin(cal.Delay, iodev.Fs);
stim_end = stim_start + outpts - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup attenuation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch cal.AttenType
    case 'VARIED'
        Latten = cal.AttenStart;
        Ratten = cal.AttenStart;	
    case 'FIXED'
        Latten = cal.AttenFixed;	
        Ratten = cal.AttenFixed;
end
switch cal.Side 
    case 'BOTH' 
        % do nothing
    case 'LEFT'
        Ratten = MAX_ATTEN;
    case 'RIGHT'
        Latten = MAX_ATTEN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now initiate sweeps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PAUSE	
pause(1)
disp([mfilename ': now running calibration...']);
% starting
STOPFLAG = 0;	
rep = 1;
freq_index = 1;
%tic % timer start

% ****** main LOOP through the frequencies ******
while ~STOPFLAG && ( freq_index <= cal.Nfreqs )
    % get the current frequency
    freq = cal.Freqs(freq_index); 
    % tell user what frequency is being played
    update_ui_str(handles.editFreqVal, freq);  
    
    if strcmp(cal.Side, 'BOTH') || strcmp(cal.Side, 'LEFT')  % LEFT    
        % setup played/silent parameters
        PLAYED = L;
        SILENT = R;
        PA5P = PA5L;  % played
        PA5S = PA5R;  % silent
        Patten = Latten;
        Satten = MAX_ATTEN;
        pmagadjval = cal.frL.magadjval;
        smagadjval = cal.frR.magadjval;
        pphiadjval = cal.frL.phiadjval;
        sphiadjval = cal.frR.phiadjval;
        editAttenP = handles.editAttenL;
        editAttenS = handles.editAttenR;
        editValP = handles.editValL;
        editValS = handles.editValR;
        editSPLP = handles.editSPLL;
        editSPLS = handles.editSPLR;
        axesStimP = handles.axesStimL;
        axesStimS = handles.axesStimR;
        axesRespP = handles.axesRespL;
        axesRespS = handles.axesRespR;
        Pcolor = 'g';
        Scolor = 'r';
        %%% main loop for recording responses and storing data %%%
        HeadphoneCal2_Run_mainloop;
        % store old value
        Latten = Patten; 
    end  % LEFT

    if strcmp(cal.Side, 'BOTH') || strcmp(cal.Side, 'RIGHT')  % RIGHT    
        % setup played/silent parameters
        PLAYED = R;
        SILENT = L;
        PA5P = PA5R;  % played
        PA5S = PA5L;  % silent
        Patten = Ratten;
        Satten = MAX_ATTEN;
        pmagadjval = cal.frR.magadjval;
        smagadjval = cal.frL.magadjval;
        pphiadjval = cal.frR.phiadjval;
        sphiadjval = cal.frL.phiadjval;
        editAttenP = handles.editAttenR;
        editAttenS = handles.editAttenL;
        editValP = handles.editValR;
        editValS = handles.editValL;
        editSPLP = handles.editSPLR;
        editSPLS = handles.editSPLL;
        axesStimP = handles.axesStimR;
        axesStimS = handles.axesStimL;
        axesRespP = handles.axesRespR;
        axesRespS = handles.axesRespL;
        Pcolor = 'r';
        Scolor = 'g';
        %%% main loop for recording responses and storing data %%%
        HeadphoneCal2_Run_mainloop;
        % store old value
        Ratten = Patten; 
    end  % RIGHT
    
    % do some adjustments and calculations
    tmpleakmags{L}(freq_index, :) =...
        tmpleakmags{L}(freq_index, :) - tmprawmags{R}(freq_index, :);
    tmpleakphis{L}(freq_index, :) =...
        tmpleakphis{L}(freq_index, :) - tmpphis{R}(freq_index, :);
    tmpleakmags{R}(freq_index, :) =...
        tmpleakmags{R}(freq_index, :) - tmprawmags{L}(freq_index, :);
    tmpleakphis{R}(freq_index, :) =...
        tmpleakphis{R}(freq_index, :) - tmpphis{L}(freq_index, :);

   % compute the averages for this frequency
   for i=1:2
    caldata.mag(i, freq_index) = mean( tmpmaxmags{i}(freq_index, :) );
    caldata.mag_stderr(i, freq_index) = std( tmpmaxmags{i}(freq_index, :) );
    caldata.phase(i, freq_index) = mean( unwrap(tmpphis{i}(freq_index, :)) );
    caldata.phase_stderr(i, freq_index) = std( unwrap(tmpphis{i}(freq_index, :)) );
    caldata.dist(i, freq_index) = mean( tmpdists{i}(freq_index, :) );
    caldata.dist_stderr(i, freq_index) = std( tmpdists{i}(freq_index, :) );

    caldata.leakmag(i, freq_index) = mean( tmpleakmags{i}(freq_index, :) );
    caldata.leakmag_stderr(i, freq_index) = std( tmpleakmags{i}(freq_index, :) );
    caldata.leakphase(i, freq_index) = mean( unwrap(tmpleakphis{i}(freq_index, :)) );
    caldata.leakphase_stderr(i, freq_index) = std( unwrap(tmpleakphis{i}(freq_index, :)) );
    caldata.leakdist(i, freq_index) = mean( tmpleakdists{i}(freq_index, :) );
    caldata.leakdist_stderr(i, freq_index) = std( tmpleakdists{i}(freq_index, :) );
   end

    % increment frequency index counter
	freq_index = freq_index + 1;
	% check if user pressed ABORT button 
	if read_ui_val(handles.buttonAbort) == 1
		disp('ABORTING Calibration...')
%		cal.timer = toc;
		break;
    end

end %****** end of cal loop
%cal.timer = toc; % get the time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exit gracefully (close TDT objects, etc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HeadphoneCal2_Run_tdtexit;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if we made it to the end of the frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if freq == cal.F(3) % if yes, complete
	COMPLETE = 1;
else 
	COMPLETE = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save handles and data and temp file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.h2.caldata = caldata;
%handles.h2.rawdata = rawdata;
handles.h2.cal = cal;
guidata(hObject, handles);

[fname, fpath] = uiputfile('*_cal2.mat', 'Save CAL Data');
if fname
	save(fullfile(fpath, fname), 'caldata', '-mat');
	save([datestr(now,'yyyy-mm-dd-HHMM') '_cal2.mat'], 'caldata', '-mat');
else
	save([datestr(now,'yyyy-mm-dd-HHMM') '_cal2.mat'], 'caldata', '-mat');
end

	