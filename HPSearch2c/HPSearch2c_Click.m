% HPSearch2c_Click.m 
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch2c "CLICK" routine.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Based on HPSearch Curve routines 
%  (HPSearch, HPCurve_buildStimCache, HPCurve_playCache): 2009-2011 by SJS
% Click Version Written (HPSearch2_Click): Mar 2012 by GA
% Adopted for HPSearch2a (HPSearch2a_Click): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_Click): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_Click): Jan 2015 by GA 
%  --- plotting has been made faster 
%------------------------------------------------------------------------

disp('#### HPSearch2_Click called ###')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preliminary settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 1;
R = 2;
MAXATTEN = 120;
MINATTEN = 0;

% DAscale is fixed to 5 Volts for clicks
DAscale = 5;

% make some local copies of config structs to simplify
indev = handles.indev;
outdev = handles.outdev;
zBUS = handles.zBUS;
tdt = handles.h2.tdt;
stimulus = handles.h2.stimulus;
channels = handles.h2.channels;
analysis = handles.h2.analysis;
animal = handles.h2.animal;
click = handles.h2.click;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting I/O parameters to TDT circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% delay will be included in the stimulus waveform
% so for TDT settings, delay should be zero
tmpstimulus = stimulus; 
tmpstimulus.Delay = 0; 

% set TDT
Fs = handles.h2.config.TDTsetFunc(indev, outdev, tdt, tmpstimulus, channels);

% sampling rates 
inFs = Fs(1);
outFs = Fs(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% number of points to acquire or send out
% if # of channels N is more than one, then acqpts will be multipled by N
acqpts = ms2samples(tdt.AcqDuration, inFs);
outpts = ms2samples(stimulus.Duration, outFs);

% some vectors for plots
tvec = 1000*(0:acqpts-1)/inFs; % (ms)
wpst = 0.5; % pst bin width (ms)
tpst = ( 0 : wpst : tdt.AcqDuration ); 
vpst = zeros(1, length(tpst) ); 
wisi = 0.05; % isi bin width (ms)
tisi = ( 0 : wisi : 10 );
visi = zeros(1, length(tisi) ); 
nspiketotal = 0;
nspikelimit = 1000;
rasterindex = 0;
rasterlimit = analysis.Raster; % how many reps are shown
ctotal = zeros(1,length(tvec)); % for the Curve plot

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
set(handles.axesCurve, 'NextPlot', 'replacechildren');
set(handles.axesUpclose, 'NextPlot', 'replacechildren');
set(handles.axesPSTH, 'NextPlot', 'replacechildren');
set(handles.axesISIH, 'NextPlot', 'replacechildren');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if monaural, then ITD is ignored (reset to defaults)
switch upper(click.side)
    case { 'LEFT', 'RIGHT' } 
        click.ITD = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get data/stim filename info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[clickfile, clickpath] = TytoLogy2_buildFileName(animal, 'CLICK');
% if clickfilename == 0, user selected 'cancel',  
% so cancel the running of click and return from function
if clickfile == 0
    ClickSuccessFlag = -1; 
    return;
end

% mat file to save click results
[pathstr, filestr, extstr] = fileparts(clickfile);
clicksettingsfile = [pathstr filesep filestr '.mat'];
clickdat2file = [pathstr filesep filestr '.dat2'];

% display info
disp(['data saved to: ' pathstr filesep filestr '.mat(.dat2)' ]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a comment parameter
% this is a temporary thing, will need to create a UI for this (SJS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
animal.comments = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make stimulus cache variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ntrials = length(click.ITD);
nreps = click.Reps;
nstims = nreps * ntrials;

% attenuator values
atten = [MAXATTEN MAXATTEN]; % default = max atten

% set LeftON/RightON flags 
switch upper(click.side)
    case 'BOTH'
        LeftON = 1;
        RightON = 1;
        atten(L) = click.Latten;
        atten(R) = click.Ratten;
    case 'LEFT'
        LeftON = 1;
        RightON = 0;
        atten(L) = click.Latten;
    case 'RIGHT'
        LeftON = 0;
        RightON = 1;
        atten(R) = click.Ratten;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomize trial presentations
% --- source from HPCurve_randomSequence by SJS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make random sequence
stimseq = zeros(nreps, ntrials);
for ireps = 1:nreps
    stimseq(ireps, :) = randperm(ntrials);
end
% store the random sequence to clickcache
clickcache.trialRandomSequence = stimseq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set loop variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rep and trial numbers 
repnum = zeros(nstims, 1);
trialnum = zeros(nstims, 1);
stimitd = zeros(nstims,1);

% Note:: stimitd: randomized, click.itd: sorted
sindex = 0;
for ireps = 1:nreps
    for itrials = 1:ntrials
        sindex = sindex + 1;
		repnum(sindex) = ireps;
		trialnum(sindex) = itrials;
        stimitd(sindex) = click.ITD(stimseq(ireps,itrials));
    end
end

% store unsorted and sorted itd values to clickcache
clickcache.itd      = zeros(ntrials, nreps);
clickcache.itd_sort = zeros(ntrials, nreps);

for sindex = 1:nstims 
    rep   = repnum(sindex); 
    trial = trialnum(sindex); 
    clickcache.itd(trial, rep) = stimitd(sindex); 
    clickcache.itd_sort(stimseq(rep, trial), rep) = stimitd(sindex); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize cells and arrays for storing data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make cells to store data
resp = cell(ntrials, nreps); % sorted raw data traces
spike_times = cell(ntrials, nreps); 
spike_counts = zeros(ntrials, nreps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write data file header - this will create a binary data file
% Adopted from writeDataFileHeader with modification (Aug 2012, GA)
% writeDataFileHeader2(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the date and time
time_start = now;

% create binary file 
fp = fopen(clickdat2file, 'w');

% if something is wrong with file opening, then abort
if fp==-1
    warndlg('Click module -- Cannot create a binary file');
    ClickSuccessFlag = -1; 
    return; 
end

%-------------------------
% write the header info
%-------------------------
% write the filename 
TytoLogy2_writebinary(fp, 'string', clickdat2file, 'datafile');
% write a string that says 'HEADER_START'
TytoLogy2_writebinary(fp, 'string', 'HEADER_START', '???');
% write the start time (use datestr(timevalue) to get human readable form)
TytoLogy2_writebinary(fp, 'vector', time_start, 'time_start', 'double');
% write the data version
TytoLogy2_writebinary(fp, 'vector', HPSearch2c_init('DATAVERSION'), 'dataversion', 'double');
% write the stim structure
TytoLogy2_writebinary(fp, 'struct', stimulus, 'stim');
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
% write the click structure
TytoLogy2_writebinary(fp, 'struct', click, 'click');
% write DAscale 
TytoLogy2_writebinary(fp, 'vector', DAscale, 'DAscale', 'double');
% write the stimcache structure
TytoLogy2_writebinary(fp, 'struct', clickcache, 'clickcache');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect spont data to adjust threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spontatten = [MAXATTEN MAXATTEN]; % max attenuation
handles.h2.config.setattenFunc(handles.PA5L, spontatten(L));
handles.h2.config.setattenFunc(handles.PA5R, spontatten(R));
Sn = zeros(2,ms2bin(stimulus.Duration, outFs));
[sponttrace, spontnpts, sponttraceu, spontnptsu] = ...
    handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);
% if no input, then make a dummy trace 
if std(sponttrace) == 0
    sponttrace = 0.1*randn(size(sponttrace));
end
% calculate SD of the spont trace as threshold reference
refSD = std(sponttrace);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop: play sound, collect spikes, analyze data, and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize flags and counters
sindex = 0;
cancelFlag = 0;
isistr = sprintf('Starting Click\n');

% set attenuators 
% Note: the function handle 'handles.h2.config.setattenFunc' is 
%       defined in HPSearch2c_config()
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));

while ~cancelFlag && (sindex < nstims)

    %-------------------------------------
    % set up indeces
    %-------------------------------------
    sindex = sindex + 1;
    rep = repnum(sindex);
    trial = trialnum(sindex);

    %-------------------------------------
    % show stimulus information to user
    %-------------------------------------
    str0 = sprintf('rep = %d/%d  (%d/%d) :  ', rep, nreps, sindex, nstims);
    str1 = sprintf('ITD = %.0f\n', stimitd(sindex));
    update_ui_str(handles.textMessage, [ isistr str0 str1 'Output: ', clickfile ]);

    %-------------------------------------
    % generate click
    %-------------------------------------

    % first make binaural stim
    Sn = syn_headphone_click(stimulus.Duration, stimulus.Delay, outFs, ...
                             click.Samples, clickcache.itd(trial, rep), ...
                             click.clicktype); 

    % set zero to channels that are off
    Sn(L,:) = Sn(L,:) * LeftON * DAscale; 
    Sn(R,:) = Sn(R,:) * RightON * DAscale; 

    %-------------------------------------
    % now play the sound and return the response
    % Note: the function handle 'handles.h2.config.ioFunc' is 
    %       defined in HPSearch2c_config()
    %-------------------------------------
    [datatrace, npts, datatraceu, nptsu] = ...
        handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);

    %-------------------------------------
    % start timer to measure ISI
    %-------------------------------------
    tic; 

    %------------------------------------- 
    % save recorded data to the binary file
    %-------------------------------------
    % open binary file to append data 
    fp = fopen(clickdat2file, 'a');

    % if something is wrong with file opening, then give a warning
    if fp==-1
        warndlg('Click module -- Cannot open a binary file');
    else
        % write the dataID
        TytoLogy2_writebinary(fp, 'vector', stimitd(sindex), 'loopvar', 'double');
        % write the trial Number
        TytoLogy2_writebinary(fp, 'vector', trial, 'trial', 'int32');
        % write the rep number
        TytoLogy2_writebinary(fp, 'vector', rep, 'rep', 'int32');
        % write the datatrace 
        TytoLogy2_writebinary(fp, 'vector', datatrace, 'datatrace', 'double');
        % write the datatraceu (unfiltered data)
        TytoLogy2_writebinary(fp, 'vector', datatraceu, 'datatraceu', 'double');
        % close the file
        fclose(fp);
    end

    %-------------------------------------
    % store response data to cell array 
    % Note: by indexing the response using row values from the stimseq 
    %       array, the resp{} data will be in SORTED form! (SJS)
    %-------------------------------------
	resp{stimseq(rep, trial), rep} =  datatrace';

    %-------------------------------------
    % reading analysis/plotting settings from UI
    %-------------------------------------
    plotparams = HPSearch2c_plotParamFromUI(handles);

    %-------------------------------------
    % determine threshold
    %-------------------------------------
    if plotparams.ThAuto  % if automatic threshold 
        % calulate threshold
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

    %-------------------------------------
    % spike detection 
    %-------------------------------------
    dwin = ms2samples(analysis.WindowWidth, inFs);
    spidx = HPSearch2c_spikedetect(datatrace, thval, dwin, plotparams.Peak);

    % calculating spike rate within the entire time length
    a_nspike = sum(spidx);
    a_rate = 1000 *  a_nspike / (stimulus.Duration);
    % show spike rate
    update_ui_str(handles.editRate, a_rate);

    % store data 
    spike_times{stimseq(rep, trial), rep} = tvec(spidx);
    spike_counts(stimseq(rep, trial), rep) = a_nspike;

    %-------------------------------------
    % plotting data
    %-------------------------------------
    % dummy frequency info used for plots
    plotparams.minfreq = 1000; 
    plotparams.maxfreq = 2000;
    
    % call plotting script
    HPSearch2c_plotResponse;

    % Curve plot
    ctotal = ctotal + datatrace; % used for average waveform 
    if plotparams.plotCurve

        % plotting 
        set( handles.axesCurve, 'NextPlot', 'replace' ); % = hold off 
        plot( handles.axesCurve, tvec, ctotal/sindex, 'b'); 
        % find peak
        [m,i] = max(abs(ctotal));
        % set X limit 
        xl = max([stimulus.Delay tvec(i)]);
        set( handles.axesCurve, 'xlim', [ xl-1.5 xl+2.5 ]);
        % set Y limit
        set( handles.axesCurve, 'xlim', [ -1.5*m/sindex 1.5*m/sindex+eps ]);
    end 

    % flush buffer
%    drawnow; % this line makes plotting slow

    %-------------------------------------
    % pause for ISI
    %-------------------------------------
    elapsed_sec = toc;     % stop timer 
    isi_sec = stimulus.ISI/1000;
    isistr = sprintf('ISI = %s sec\n', num2str( max([elapsed_sec,isi_sec]) ));
    if elapsed_sec < isi_sec;
        pause(isi_sec - elapsed_sec); 
    end

    %-------------------------------------
    % check if user pressed the Pause button
    % if Abort button is pressed, then quit pausing 
    % and go to the next step to handle the abort flag 
    %-------------------------------------
    while read_ui_val(handles.buttonPause) ...
        && ~read_ui_val(handles.buttonAbort)
        drawnow;
        pause(0.5);
    end

    %-------------------------------------
    % check if user pressed the Abort button
    %-------------------------------------
	cancelFlag = read_ui_val(handles.buttonAbort);

end % end of while loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the end of data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the finish time
time_end = now;

% open the file for appending
fp = fopen(clickdat2file, 'a');

% if something is wrong with file opening, then do nothing
if fp==-1
    warndlg('Click module -- Cannot open a binary file');
else
    % write a string that says 'DATA_END'
    TytoLogy2_writebinary(fp, 'string', 'DATA_END', '???')
    % write the end time 
    TytoLogy2_writebinary(fp, 'vector', time_end, 'time_end', 'double');
    % close the file
    fclose(fp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gather collected data into clickdata structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clickdata = [];
if ~cancelFlag
    clickdata.itd = clickcache.itd; % unsorted
    clickdata.itd_sort = clickcache.itd_sort; % sorted
    clickdata.spike_times = spike_times; % sorted
    clickdata.spike_counts = spike_counts; % sorted
end
% save cancel flag status in curvedata
clickdata.cancelFlag = cancelFlag;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save curve data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(clickdata) && ~cancelFlag

    % store start and stop times and data version
    clicksettings.time_start = datestr(time_start);
    clicksettings.time_stop = datestr(time_end);
    clicksettings.dataversion = HPSearch2c_init('DATAVERSION');
    clicksettings.clicksettingsfile = clicksettingsfile;
    % store various settings structs to curvesetting
    clicksettings.stim = stimulus;
    clicksettings.tdt = tdt;
    clicksettings.channels = channels;
    clicksettings.analysis = analysis;
    clicksettings.animal = animal;
    clicksettings.DAscale = DAscale;
    clicksettings.click = click;
    clicksettings.Fs = Fs;

    %-------------------------------------
    % save the clicksettings struct (has curve information) and 
    % the clickdata struct (has curve data spike counts but NO RAW DATA!).  
    % IMPORTANT: remember that the data in curve data are already sorted 
    %            into a [# of test values X # of reps] array (SJS)
    %-------------------------------------
    clickresp = resp;
    save(clicksettingsfile, '-MAT', 'clicksettings', 'clickdata', 'clickresp');

    % if succeeded then flag=1
    ClickSuccessFlag = 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot curve data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(clickdata) && ~cancelFlag

TytoView_clickplot(clickdata, clicksettings);

else

    if cancelFlag
        update_ui_str(handles.textMessage, 'Click Aborted');
        disp('Aborted');
    else
        warndlg('Error in running Click.'); 
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some cleanup before exit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% save handles structure 
guidata(hObject, handles);
