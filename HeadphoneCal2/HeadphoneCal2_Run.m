%--------------------------------------------------------------------------
% HeadphoneCal2_Run.m
%--------------------------------------------------------------------------
%  Script that runs the calibration protocol
%    This script is called by HeadphoneCal2.m
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Original Versions Written (HeadphoneCal_RunCalibration, 
%    HeadphoneCal_settings, HeadphoneCal_tdtinit, 
%    HeadphoneCal_caldata_init, HeadphoneCal_tdtexit): 2008-2010 by SJS
% Upgraded Version Created (HeadphoneCal2_Run): 2011-2012 by GA
%------------------------------------------------------------------------
% Notes (Apr 2012, GA)
%  Function handles are stored under the config structure and 
%  defined in HeadphoneCal2_init.m
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display message
str = 'Initial setup for calibration'; 
set(handles.textMessage, 'String', str);
% general constants
L = 1; 
R = 2;
MAX_ATTEN = 120;
% making a local copy of the cal settings structure
cal = handles.h2.cal;
fr = handles.h2.fr;

% check if FR files are loaded
switch cal.Side 
    case 'BOTH' 
        if ~(fr.loadedR && fr.loadedL)
            str = 'Load FR files (L and R) before calibration!'; 
            set(handles.textMessage, 'String', str);
            errordlg(str, 'FR file error');
            return;
        end
        cal.frL = fr.frdataL; 
        cal.frR = fr.frdataR; 
        cal.frfileL = fr.frfileL;
        cal.frfileR = fr.frfileR;

    case 'LEFT'
        if ~fr.loadedL
            str = 'Load FR file (L) before calibration!'; 
            set(handles.textMessage, 'String', str);
            errordlg(str, 'FR file error');
            return;
        end
        cal.frL = fr.frdataL; 
        cal.frR = HeadphoneCal2_dummyFR; % dummy data struct for R
        cal.frfileL = fr.frfileL;
        cal.frfileR = [];
        
    case 'RIGHT'
        if ~fr.loadedR
            str = 'Load FR file (R) before calibration!'; 
            set(handles.textMessage, 'String', str);
            errordlg(str, 'FR file error');
            return;
        end
        cal.frL = HeadphoneCal2_dummyFR; % dummy data struct for L
        cal.frR = fr.frdataR; 
        cal.frfileL = [];
        cal.frfileR = fr.frfileR;
end

% I/O channels
cal.OutChanL = handles.h2.config.OutChanL;
cal.OutChanR = handles.h2.config.OutChanR;
cal.InChanL = handles.h2.config.InChanL;
cal.InChanR = handles.h2.config.InChanR;
% Calibration Settings
cal.RefMicSens = [cal.frL.cal.RefMicSens cal.frR.cal.RefMicSens];
cal.VtoPa = cal.RefMicSens.^-1;  % Volts to Pascal factor
cal.MicGain_dB = [cal.frL.cal.MicGain_dB cal.frR.cal.MicGain_dB];
cal.MicGain = 10.^(cal.MicGain_dB./20); % mic gain factor
% Frequencies
cal.F = [cal.Fmin cal.Fstep cal.Fmax];
cal.Freqs = cal.Fmin : cal.Fstep : cal.Fmax;
cal.Nfreqs = length(cal.Freqs);
% pre-compute the sinusoid RMS factor
cal.RMSsin = 1/sqrt(2);  

% check low freq limit
if cal.Freqs(1) < max( cal.frL.Freqs(1), cal.frR.Freqs(1) )
    str = 'requested LF calibration limit is out of FR file bounds'; 
    set(handles.textMessage, 'String', str);
    errordlg(str, 'FR file error');
    return;
end
% check high freq limit
if cal.Freqs(end) > min( cal.frL.Freqs(end), cal.frR.Freqs(end) )
    str = 'requested HF calibration limit is out of FR file bounds'; 
    set(handles.textMessage, 'String', str);
    errordlg(str, 'FR file error');
    return;
end

% fetch the L and R headphone mic adjustment values for the 
% calibration frequencies using interpolation
cal.frL.magadjval = interp1(cal.frL.Freqs, cal.frL.adjmag, cal.Freqs);
cal.frR.magadjval = interp1(cal.frR.Freqs, cal.frR.adjmag, cal.Freqs);
cal.frL.phiadjval = interp1(cal.frL.Freqs, cal.frL.adjphi, cal.Freqs);
cal.frR.phiadjval = interp1(cal.frR.Freqs, cal.frR.adjphi, cal.Freqs);
handles.h2.cal = cal;
guidata(hObject, handles);

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
% setup storage variables -- caldata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
caldata.version = '2.1';
caldata.time_str = datestr(now, 31);        % date and time
caldata.timestamp = now;                % timestamp
caldata.adFc = iodev.Fs;                % analog input rate 
caldata.daFc = iodev.Fs;                % analog output rate 
caldata.F = cal.F;                    % freq range (matlab string)
caldata.Freqs = cal.Freqs;            % frequencies (matlab array)
caldata.Nfreqs = cal.Nfreqs;                % number of freqs to collect
caldata.Reps = cal.Reps;                % reps per frequency
caldata.cal = cal;                   % parameters for calibration session
caldata.frdataL = cal.frL;    % FR data
caldata.frdataR = cal.frR;    % FR data
caldata.frfileL = cal.frfileL;  % FR file name
caldata.frfileR = cal.frfileR;  % FR file name
caldata.DAlevel = cal.DAlevel;        % output peak voltage level
caldata.Side = cal.Side;
caldata.AttenType = cal.AttenType;
switch cal.AttenType
    case 'VARIED'
    caldata.Atten = cal.AttenStart;        % initial attenuator setting
    caldata.max_spl = cal.MaxLevel;        % maximum spl (will be determined in program)
    caldata.min_spl = cal.MinLevel;        % minimum spl (will be determined in program)
    case 'FIXED'
    caldata.Atten = cal.AttenFixed;        % initial attenuator setting
    caldata.max_spl = cal.AttenFixed;    % maximum spl (will be determined in program)
    caldata.min_spl = cal.AttenFixed;    % minimum spl (will be determined in program)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up arrays to hold data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpcell = cell(2,1);  % L = 1; R = 2; 
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

% initialize the caldata structure arrays for the calibration data
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup cell for raw data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rawdata.Freqs = caldata.Freqs;
rawdata.resp = cell(cal.Nfreqs, cal.Reps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the start and end bins for the calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% setup initial attenuation
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
% display message
str = 'Now Running Calibration';
set(handles.textMessage, 'String', str);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% go to main loop for recording responses and storing data %%%
        HeadphoneCal2_Run_mainloop;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % store old value for the next freq
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% go to main loop for recording responses and storing data %%%
        HeadphoneCal2_Run_mainloop;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % store old value for the next freq 
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
    for i=1:2 % L = 1, R = 2
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

    % check if STOP_FLG is set
    if STOPFLAG
        str = 'STOPFLAG detected';
        set(handles.textMessage, 'String', str);
        if STOPFLAG == -1 
            errordlg('Attenuation maxed out!', 'Attenuation error');
        elseif STOPFLAG == -2
            errordlg('Attenuation at minimum level!', 'Attenuation error');
        end
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
else % if not, skip the saving and return 
    handles.h2.COMPLETE = 0;
    handles.h2.caldata = caldata;
    handles.h2.rawdata = rawdata;
    guidata(hObject, handles);    
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data to file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fname, fpath] = uiputfile('*_cal2.mat', 'Save CAL Data');
if handles.h2.cal.SaveRawData
    save('temp_cal2.mat', 'caldata', 'rawdata', '-mat');
    if fname
        save(fullfile(fpath, fname), 'caldata', 'rawdata', '-mat');
    end
else 
    save('temp_cal2.mat', 'caldata', '-mat');
    if fname
        save(fullfile(fpath, fname), 'caldata', '-mat');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save handles and data and temp file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.h2.caldata = caldata;
handles.h2.rawdata = rawdata;
guidata(hObject, handles);

