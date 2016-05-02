% HPSearch2c_Search.m
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch2c "Run (External) Stim" routine.
%
%------------------------------------------------------------------------
% Notes: zBUS, indev, outdev, PA5L and PA5R are assumed to be already 
% initialized when this routine is called. This means that the TDTINIT 
% status has to be checked before using this routine. 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Felix Dollack
%   felix.dollack@googlemail.com
%------------------------------------------------------------------------
% Original Version Written (HPSearch_RunStim): 2015 by FD

disp('#### HPSearch2_Run_Stim called ###')

%% preliminary settings
L = 1;
R = 2;
MAXATTEN = 120;
MINATTEN = 0;

% set cancelFlag
cancelFlag = 0;

% make some local copies of config structs to simplify
indev = handles.indev;
outdev = handles.outdev;
zBUS = handles.zBUS;
tdt = handles.h2.tdt;

fileinfo = handles.h2.extstim.fileinfo;
extstim = handles.h2.extstim;

stimulus = handles.h2.stimulus;
stimulus.Delay = 0; % delay will be inroduced later or is already inside the stimulus
channels = handles.h2.channels;
analysis = handles.h2.analysis;
animal = handles.h2.animal;

% check parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if monaural, then ITD is ignored (reset to defaults)
switch upper( handles.h2.extstim.side )
    case { 'LEFT', 'RIGHT' } 
        extstim.ITD = 0;
end

%% Get data/stim filename info
[extstimfile, extstimpath] = TytoLogy2_buildFileName(animal, 'EXTSTIM');
% if extstimfile == 0, user selected 'cancel',  
% so cancel the running of Run (Ext) Stim and return from function
if extstimfile == 0
    RunSuccessFlag = -1; 
    return;
end

% mat file to save click results
[pathstr, filestr, extstr] = fileparts(extstimfile);
extstimsettingsfile = [pathstr filesep filestr '.mat'];
extstimdat2file = [pathstr filesep filestr '.dat2'];

% display info
disp(['data saved to: ' pathstr filesep filestr '.mat(.dat2)' ]);

%% change tdt and stimulus settings according to external stimulus
stimulus.Duration = ceil( extstim.fileinfo.sample_len / RPsamplefreq( indev ))*1000;
tdt.AcqDuration = stimulus.Duration + round( stimulus.ISI / 4 );
tdt.SweepPeriod = tdt.AcqDuration + 10; % 10 ms longer than the actual recording length

%% setting I/O parameters to TDT circuit
%-------------------------------------
% Note: the function handle 'handles.h2.config.TDTsetFunc' is 
%       defined in HPSearch2c_config()
%-------------------------------------
Fs = handles.h2.config.TDTsetFunc(indev, outdev, tdt, stimulus, channels);

% sampling rates 
inFs = Fs(1);
outFs = Fs(2);

%% setup for plots
% number of points to acquire or send out
acqpts = fileinfo.sample_len;
outpts = acqpts;

% some vectors for plots
tvec = 1000*( 0:acqpts-1 )/inFs; % (ms)
wpst = 0.5; % PSTH bin width (ms)
tpst = ( 0 : wpst : tdt.AcqDuration ); 
vpst = zeros(1, length(tpst) ); 
wisi = 0.05; % ISIH bin width (ms)
tisi = ( 0 : wisi : 10 );
visi = zeros(1, length(tisi) ); 
nspiketotal = 0;
nspikelimit = 1000;
rasterindex = 0;
rasterlimit = analysis.Raster;  % how many reps are shown

% clear plots
cla(handles.axesResp);
cla(handles.axesRaster);
cla(handles.axesCurve);
cla(handles.axesUpclose);
cla(handles.axesPSTH);
cla(handles.axesISIH);

% setting overwriting options
set(handles.axesResp, 'NextPlot', 'replacechildren');
set(handles.axesRaster, 'NextPlot', 'add');
set(handles.axesUpclose, 'NextPlot', 'replacechildren');
set(handles.axesPSTH, 'NextPlot', 'replacechildren');
set(handles.axesISIH, 'NextPlot', 'replacechildren');

%% merge L and R calibration data -- combine two cal files into one
mergedcaldata = TytoLogy2_mergecal( ...
    handles.h2.calinfo.loadedL, handles.h2.calinfo.loadedR, ...
    handles.h2.caldataL, handles.h2.caldataR );

% number of ITDs to test
nITD = length( extstim.ITD );

%% initialize cells and arrays for storing data
% make cells to store data
resp = cell( 1, extstim.Reps ); % sorted raw data traces
spike_times = cell( 1, extstim.Reps ); 
spike_counts = zeros( 1, extstim.Reps );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write data file header - this will create a binary data file
% Adopted from writeDataFileHeader with modification (Aug 2012, GA)
% writeDataFileHeader2(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the date and time
time_start = now;

% create binary file 
fp = fopen(extstimdat2file, 'w');

% if something is wrong with file opening, then abort
if fp==-1
    warndlg('External Stimulus module -- Cannot create a binary file');
    RunSuccessFlag = -1; 
    return; 
end

%-------------------------
% write the header info
%-------------------------
% write the filename 
TytoLogy2_writebinary(fp, 'string', extstimdat2file, 'datafile');
% write a string that says 'HEADER_START'
TytoLogy2_writebinary(fp, 'string', 'HEADER_START', '???');
% write the start time (use datestr(timevalue) to get human readable form)
TytoLogy2_writebinary(fp, 'vector', time_start, 'time_start', 'double');
% write the data version
TytoLogy2_writebinary(fp, 'vector', HPSearch2c_init('DATAVERSION'), 'dataversion', 'double');
% write the tdt structure
TytoLogy2_writebinary(fp, 'struct', tdt, 'tdt');
% write the channels structure
TytoLogy2_writebinary(fp, 'struct', channels, 'channels');
% write the analysis structure
TytoLogy2_writebinary(fp, 'struct', analysis, 'analysis');
% write the animal structure
TytoLogy2_writebinary(fp, 'struct', animal, 'animal');
% write Fs 
TytoLogy2_writebinary(fp, 'vector', Fs, 'Fs', 'double');
% write the external stimulus structure (already includes information about the stimulus
tempStruct = rmfield( extstim, 'outsig' );
tempStruct.fileinfo = rmfield( extstim.fileinfo, 'stim_data' );
TytoLogy2_writebinary(fp, 'struct', tempStruct, 'extstim'); % without stimulus data (no need to save the wav file)
% write the indev data struct (indev)
TytoLogy2_writebinary(fp, 'struct', extractRPDevInfo(indev), 'indev');
% write the outdev data struct (outdev)
TytoLogy2_writebinary(fp, 'struct', extractRPDevInfo(outdev), 'outdev');
% write the end of the header string
TytoLogy2_writebinary(fp, 'string', 'HEADER_END', '???');
% write the beginning of the data string
TytoLogy2_writebinary(fp, 'string', 'DATA_START', '???');

% close the file
fclose(fp);


%% collect spont data to adjust threshold
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spontatten = [MAXATTEN MAXATTEN]; % max attenuation
handles.h2.config.setattenFunc(handles.PA5L, spontatten(L));
handles.h2.config.setattenFunc(handles.PA5R, spontatten(R));
Sn = zeros( 2, acqpts );
[sponttrace, spontnpts, sponttraceu, spontnptsu] = ...
    handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);
% if no input, then make a dummy trace 
if std(sponttrace) == 0
    sponttrace = 0.1*randn(size(sponttrace));
end
% calculate SD of the spont trace as threshold reference
refSD = std(sponttrace);

stimuli2do = extstim.Reps * nITD; % # of stims to do
stimulusCount = 0; % counter for # of stims
currentITD = 0;
%% Main part: play sound, collect spikes, analyze data, and plot
isistr = sprintf('Starting External Stimulus\n');
while( read_ui_val(hObject) && ( stimulusCount < stimuli2do ) && ~cancelFlag )  % loop while Search button is on
    if( mod( stimulusCount, extstim.Reps ) == 0 ),
        currentITD = currentITD + 1;
        %% synthesize stereo stimulus sound and apply ITD if target is BOTH sides
        tmpS   = extstim.outsig; % (resampled) external stimulus
        tmpRms = fileinfo.rms;
        switch( extstim.side ),
            case 'BOTH',
                if( fileinfo.nchan == 1 ), % if it's a monaural signal
                    S(L,:) = tmpS(:,L);
                    S(R,:) = tmpS(:,L);
                    Srms(L,:) = tmpRms;
                    Srms(R,:) = tmpRms;
                else                       % if it's a binaural signal
                    S(L,:) = tmpS(:,L);
                    S(R,:) = tmpS(:,R);
                    Srms(L,:) = tmpRms( L );
                    Srms(R,:) = tmpRms( R );
                end
                S = apply_itd_on_external_stim( S, Fs( 1 ), extstim.ITD( currentITD ), stimulus.Ramp );
            case 'LEFT',
                S(L,:) = tmpS(:,L);
                S(R,:) = zeros( 1, fileinfo.sample_len );
                Srms(L,:) = tmpRms( L );
                Srms(R,:) = 0;
            case 'RIGHT',
                S(L,:) = zeros( 1, fileinfo.sample_len );
                Srms(L,:) = tmpRms( L );
                if( fileinfo.nchan == 2 ),
                    S(R,:) = tmpS(:,R);
                    Srms(R,:) = tmpRms( R );
                else
                    S(R,:) = tmpS(:,L);
                    Srms(R,:) = tmpRms( L );
                end
            otherwise,
                fprintf( 'wrong side!' );
        end
        
        %% compute attenuator settings
        if( strcmpi( extstim.cal, 'USE' )),
            spl_val = [65 65];
            
            % note: TytoLogy2_figure_atten() returns MAX_ATTEN if channel is off
            attenLcal = TytoLogy2_figureAtten( ...
                spl_val(L), Srms(L), mergedcaldata.mindbspl(L), handles.h2.calinfo.loadedL );
            attenRcal = TytoLogy2_figureAtten( ...
                spl_val(R), Srms(R), mergedcaldata.mindbspl(R), handles.h2.calinfo.loadedR );
            
            attenLuser = extstim.Latten;
            attenRuser = extstim.Ratten;
            
            attenL = attenLcal + attenLuser;
            attenR = attenRcal + attenRuser;
        else
            % only use user defined gain
            attenL = extstim.Latten;
            attenR = extstim.Ratten;
        end
        
        
        % if too loud or too faint, then give a warning
        if attenL > MAXATTEN
            warndlg('Requested Left SPL too faint');
            attenL = MAXATTEN;
            pause(5);
        elseif attenL < MINATTEN
            warndlg('Requested Left SPL too loud');
            attenL = MINATTEN;
            pause(5);
        end
        if attenR > MAXATTEN
            warndlg('Requested Right SPL too faint');
            attenR = MAXATTEN;
            pause(5);
        elseif attenR < MINATTEN
            warndlg('Requested Right SPL too loud');
            attenR = MINATTEN;
            pause(5);
        end
        
        % Note: the function handle 'handles.h2.config.setattenFunc' is
        %       defined in HPSearch2c_config()
        handles.h2.config.setattenFunc(handles.PA5L, attenL);
        handles.h2.config.setattenFunc(handles.PA5R, attenR);
    end
    % increment counter
    stimulusCount = stimulusCount + 1;
    
    %-------------------------------------
    % show stimulus information to user
    %-------------------------------------
    str0 = sprintf('rep = %d/%d\n', stimulusCount, stimuli2do );
    update_ui_str(handles.textMessage, [ isistr str0 'Output: ' extstimfile ]);
    
    %% play the sound and return the response
    %-------------------------------------
    % Note: the function handle 'handles.h2.config.ioFunc' is
    %       defined in HPSearch2c_config()
    %-------------------------------------
    [datatrace, npts, datatraceu, nptsu] = ...
        handles.h2.config.ioFunc(S, acqpts, indev, outdev, zBUS);
    
    tic;
    
    %% save recorded data to the binary file
    % open binary file to append data
    fp = fopen(extstimdat2file, 'a');
    
    % if something is wrong with file opening, then give a warning
    if fp==-1
        warndlg('External Stimulus module -- Cannot open a binary file');
    else
        % write the rep number
        TytoLogy2_writebinary(fp, 'vector', stimulusCount, 'rep', 'int32');
        % write the datatrace
        TytoLogy2_writebinary(fp, 'vector', datatrace, 'datatrace', 'double');
        % write the datatraceu (unfiltered data)
        TytoLogy2_writebinary(fp, 'vector', datatraceu, 'datatraceu', 'double');
        % close the file
        fclose(fp);
    end
    
    % store response data to cell array
    resp{ stimulusCount } =  datatrace';
    
    % reading analysis/plotting settings from UI
    plotparams = HPSearch2c_plotParamFromUI(handles);
    
    %% determine threshold
    %-------------------------------------
    if plotparams.ThAuto  % if automatic threshold
        if( ~exist( 'refSD', 'var' )),
            % use spontaneous response as reference
            refleng = max([ ms2samples( fileinfo.sample_len/outFs*1000, inFs), 2 ]);
            refresp = datatrace(1:refleng-1);
            % calulate threshold
            refSD = std(refresp);
        end
        thval = refSD * plotparams.ThresSD * plotparams.Sign;
        % showing calculated threshold [mV]
        update_ui_str(handles.editAutoTh, thval*1000);
    else
        % use manual threshold
        % param.Scale [V] -> thval [V]
        thval = plotparams.Threshold * plotparams.Scale * plotparams.Sign;
        % showing 'manual' instead of threshold
        update_ui_str(handles.editAutoTh, 'manual');
    end
    
    %% spike detection
    %-------------------------------------
    dwin = ms2samples(analysis.WindowWidth, inFs);
    spidx = HPSearch2c_spikedetect(datatrace, thval, dwin, plotparams.Peak);
    
    % calculating spike rate within the entire time length
    a_nspike = sum(spidx);
    a_rate = 1000 *  a_nspike /( acqpts );
    
    %     % showing spike rate within the analysis window
    %     a_start = ms2samples(analysis.StartTime, inFs);
    %     a_end   = ms2samples(analysis.EndTime, inFs);
    %     a_idx = [ zeros(1,a_start) ones(1,a_end-a_start), zeros(1,length(spidx)-a_end) ];
    %     a_nspike = sum( spidx & a_idx(1:length(spidx)) );
    %     a_rate = 1000 * a_nspike / (analysis.EndTime-analysis.StartTime);
    
    % show spike rate
    update_ui_str(handles.editRate, a_rate);
    
    % store data
    spike_times{ stimulusCount } = tvec(spidx);
    spike_counts( stimulusCount ) = a_nspike;
    
    %% plotting data (works till here)
    % dummy frequency info used for plots (as in clicks)
    plotparams.minfreq = 1000;
    plotparams.maxfreq = 2000;
    
    % call plotting script
    HPSearch2c_plotResponse;
    
    %% pause for ISI
    %-------------------------------------
    elapsed_sec = toc;     % stop timer
    isi_sec = stimulus.ISI/1000;
    if elapsed_sec < isi_sec;
        pause(isi_sec - elapsed_sec);
    end
    isistr = sprintf( 'ISI = %f sec\n', max([ elapsed_sec,isi_sec ]));
    update_ui_str( handles.textMessage, [ isistr, 'Output: ', extstimfile ]);
    
    % check if user pressed the Abort button
    cancelFlag = read_ui_val(handles.buttonAbort);
end

%% write the end of data file
% get the finish time
time_end = now;

% open the file for appending
fp = fopen(extstimdat2file, 'a');

% if something is wrong with file opening, then do nothing
if fp==-1
    warndlg('External Stimulus module -- Cannot open a binary file');
else
    % write a string that says 'DATA_END'
    TytoLogy2_writebinary(fp, 'string', 'DATA_END', '???')
    % write the end time 
    TytoLogy2_writebinary(fp, 'vector', time_end, 'time_end', 'double');
    % close the file
    fclose(fp);
end

%% gather collected data into clickdata structure
extstimdata = [];
if ~cancelFlag
    extstimdata.spike_times = spike_times; % sorted
    extstimdata.spike_counts = spike_counts; % sorted
end
% save cancel flag status in extstimdata
extstimdata.cancelFlag = cancelFlag;

%% Save curve data
if ~isempty(extstimdata) && ~cancelFlag
    % store start and stop times and data version
    extstimsettings.time_start = datestr(time_start);
    extstimsettings.time_stop = datestr(time_end);
    extstimsettings.dataversion = HPSearch2c_init('DATAVERSION');
    extstimsettings.extstimsettingsfile = extstimsettingsfile;
    extstimsettings.tdt = tdt;
    extstimsettings.channels = channels;
    extstimsettings.analysis = analysis;
    extstimsettings.animal = animal;
    tempStruct = rmfield( extstim, 'outsig' ); % remove played signal from savefile
    tempStruct.fileinfo = rmfield( extstim.fileinfo, 'stim_data' ); % remove data of original file
    extstimsettings.extstim = tempStruct; % without stimulus data (no need to save the wav file)
    extstimsettings.Fs = Fs;

    %-------------------------------------
    % save the extstimsettings struct (has curve information) and 
    % the extstimdata struct (has curve data spike counts but NO RAW DATA!).  
    % IMPORTANT: remember that the data in curve data are already sorted 
    %            into a [# of test values X # of reps] array (SJS)
    %-------------------------------------
    extstimresp = resp;
    save(extstimsettingsfile, '-MAT', 'extstimsettings', 'extstimdata', 'extstimresp');

    % if succeeded then flag=1
    RunSuccessFlag = 1;
end

%% some cleanup before exit
% before exit, set the attenuator to max attenuation  
% Note: the function handle 'handles.h2.config.setattenFunc' is 
%       defined in HPSearch2c_config()
atten = [MAXATTEN MAXATTEN];
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));

% if aborted then reset the Abort and Pause buttons
if cancelFlag
    update_ui_val(handles.buttonAbort,0);
    update_ui_val(handles.buttonPause,0);       
    update_ui_str(handles.buttonPause, 'Pause');
end

% eof