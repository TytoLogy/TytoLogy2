% FOCHS_Click.m 
%------------------------------------------------------------------------
% 
% Script that runs the FOCHS "CLICK" routine.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%    sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (HPSearch, HPCurve_buildStimCache, HPCurve_playCache): 2009-2011 by SJS
% Upgraded Version (HPSearch2_Click): 2011-2012 by GA
% Four-channel Input Version (FOCHS_Click): 2012 by GA  
%------------------------------------------------------------------------

% display message
str = '#### FOCHS_Click called ###'; 
update_ui_str(handles.textMessage, str);
disp(str)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preliminary settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 1;
R = 2;

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
%-------------------------------------
% Note: the function handle 'handles.h2.config.TDTsetFunc' is 
%       defined in FOCHS_config()
%-------------------------------------
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

% timebins for analysis
a_start = max([ ms2bin(analysis.StartTime, inFs), 1]);
a_end   = min([ ms2bin(analysis.EndTime, inFs), acqpts ]);

% some vectors for plots
tvec = 1000*(0:acqpts-1)/inFs; % (ms)

% clear plots
axesResp = handles.axesResp;
axesUpclose = handles.axesUpclose;
cla(axesResp);
cla(axesUpclose);

% setting overwriting options
set(axesResp, 'NextPlot', 'replacechildren');
set(axesUpclose, 'NextPlot', 'replacechildren');

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
% if user selected 'cancel', then return from function
if clickfile == 0
    ClickSuccessFlag = -1; 
    return;
end
disp(['data saved to: ' clickfile]);

% mat file to save click results
[pathstr, filestr, extstr] = fileparts(clickfile);
clicksettingsfile = [pathstr filesep filestr '.mat'];

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
atten = [120 120]; % default = max atten

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
tmpitd = zeros(nstims,1);

% Note:: click.itd: sorted, tmpitd: randomized
sindex = 0;
for ireps = 1:nreps
    for itrials = 1:ntrials
        sindex = sindex + 1;
        repnum(sindex) = ireps;
        trialnum(sindex) = itrials;
        tmpitd(sindex) = click.ITD(stimseq(ireps,itrials));
    end
end

% store unsorted and sorted itd values to clickcache
clickcache.itd      = zeros(ntrials, nreps);
clickcache.itd_sort = zeros(ntrials, nreps);

for sindex = 1:nstims 
    rep   = repnum(sindex); 
    trial = trialnum(sindex); 
    clickcache.itd(trial, rep) = tmpitd(sindex); 
    clickcache.itd_sort(stimseq(rep, trial), rep) = tmpitd(sindex); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize cells and arrays for storing data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the date and time
time_start = now;

% make cells to store data
resp1 = cell(ntrials, nreps); % sorted raw data traces for Channel 1
resp2 = cell(ntrials, nreps); % sorted raw data traces for Channel 2
resp3 = cell(ntrials, nreps); % sorted raw data traces for Channel 3
resp4 = cell(ntrials, nreps); % sorted raw data traces for Channel 4
fit_amp  = zeros(4,ntrials, nreps);
fit_freq = zeros(4,ntrials, nreps);
fit_phi  = zeros(4,ntrials, nreps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write data file header - this will create the binary data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writeDataFileHeader2(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect spont data (to be used as a reference)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spontatten = [120, 120]; % max attenuation
% handles.h2.config.setattenFunc(handles.PA5L, spontatten(L));
% handles.h2.config.setattenFunc(handles.PA5R, spontatten(R));
% Sn = zeros(2,ms2bin(stimulus.Duration, outFs));
% [sponttrace, spontnpts, sponttraceu, spontnptsu] = ...
%     handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);
% if std(sponttrace) == 0
%     sponttrace = 0.1*randn(size(sponttrace));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop: play sound, collect spikes, analyze data, and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize flags and counters
sindex = 0;
cancelFlag = 0;
isistr = sprintf('Starting Click\n');

% set attenuators 
%-------------------------------------
% Note: the function handle 'handles.h2.config.setattenFunc' is 
%       defined in FOCHS_config()
%-------------------------------------
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
    str0 = sprintf('rep = %d/%d  (%d/%d) \n', rep, nreps, sindex, nstims);
    str1 = sprintf('ITD = %.0f\n', clickcache.itd(trial, rep));
    update_ui_str(handles.textMessage, [ isistr str0 str1 ]);

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
    %       defined in HPSearch2_config()
    %-------------------------------------
    [trace1, npts1, trace2, npts2, trace3, npts3, trace4, npts4] = ...
        handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);

    %-------------------------------------
    % start timer to measure ISI
    %-------------------------------------
    tic; 

    %------------------------------------- 
    % Save Data
    %-------------------------------------
    % writeTrialData(datafile, datatrace, stimcache.stimvar{sindex}, trial, rep);

    %-------------------------------------
    % store response data to cell array 
    % Note: by indexing the response using row values from the stimseq array, 
    %       the resp{} data will be in SORTED form! (SJS)
    %-------------------------------------
    resp1{stimseq(rep, trial), rep} =  trace1';
    resp2{stimseq(rep, trial), rep} =  trace2';
    resp3{stimseq(rep, trial), rep} =  trace3';
    resp4{stimseq(rep, trial), rep} =  trace4';

    %-------------------------------------
    % data analysis / sine curve fitting
    %-------------------------------------    
    fq0 = 0; 

    % resp #1 
    rvec = trace1(a_start:a_end); % response vector to be analyzed 
    [ amp1, fq1, ph1 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, 'CLICK'); 
    std1 = abs(max(rvec)); 

    % resp #2 
    rvec = trace2(a_start:a_end); % response vector to be analyzed 
    [ amp2, fq2, ph2 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, 'CLICK'); 
    std2 = abs(max(rvec)); 

    % resp #3 
    rvec = trace3(a_start:a_end); % response vector to be analyzed 
    [ amp3, fq3, ph3 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, 'CLICK'); 
    std3 = abs(max(rvec)); 

    % resp #4 
    rvec = trace4(a_start:a_end); % response vector to be analyzed 
    [ amp4, fq4, ph4 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, 'CLICK'); 
    std4 = abs(max(rvec)); 

    %-------------------------------------
    % show stats (in mV)
    %-------------------------------------
    update_ui_str(handles.editAmpCh1, sprintf('%.4f',amp1*1000));
    update_ui_str(handles.editAmpCh2, sprintf('%.4f',amp2*1000));
    update_ui_str(handles.editAmpCh3, sprintf('%.4f',amp3*1000));
    update_ui_str(handles.editAmpCh4, sprintf('%.4f',amp4*1000));

    update_ui_str(handles.editFreqCh1, sprintf('%.1f',fq1));
    update_ui_str(handles.editFreqCh2, sprintf('%.1f',fq2));
    update_ui_str(handles.editFreqCh3, sprintf('%.1f',fq3));
    update_ui_str(handles.editFreqCh4, sprintf('%.1f',fq4));

    update_ui_str(handles.editPhiCh1, sprintf('%.1f',ph1));
    update_ui_str(handles.editPhiCh2, sprintf('%.1f',ph2));
    update_ui_str(handles.editPhiCh3, sprintf('%.1f',ph3));
    update_ui_str(handles.editPhiCh4, sprintf('%.1f',ph4));

    update_ui_str(handles.editSTDCh1, sprintf('%.4f',std1*1000));
    update_ui_str(handles.editSTDCh2, sprintf('%.4f',std2*1000));
    update_ui_str(handles.editSTDCh3, sprintf('%.4f',std3*1000));
    update_ui_str(handles.editSTDCh4, sprintf('%.4f',std4*1000));

    %-------------------------------------
    % calculating offsets for plots
    %-------------------------------------
    s1 = std1 * handles.h2.plots.Ch1; 
    s2 = std2 * handles.h2.plots.Ch2; 
    s3 = std3 * handles.h2.plots.Ch3; 
    s4 = std3 * handles.h2.plots.Ch4; 

    s9 = max([s1, s2, s3, s4]); 
    thres   = [5e-4, 15e-4, 5e-3, 15e-3, 5e-2, 15e-2, 5e-1, 15e-1, 5];
    offsets = [1e-3, 3e-3, 1e-2, 3e-2, 1e-1, 3e-1, 1, 3, 10, 30];
    offset0 =  offsets( sum(s9>thres) + 1 ); 

    offset1 = 0;
    offset2 = offset0 * 1;
    offset3 = offset0 * 2;
    offset4 = offset0 * 3;

    %-------------------------------------
    % plotting data
    %-------------------------------------
    % --- response
    if handles.h2.plots.plotResp 
        axes(axesResp);
        cla; % clear fig
        hold on;
        if handles.h2.plots.Ch1 
            plot(tvec, (trace1+offset1)*1000, 'b');
        end
        if handles.h2.plots.Ch2 
            plot(tvec, (trace2+offset2)*1000, 'r');
        end
        if handles.h2.plots.Ch3 
            plot(tvec, (trace3+offset3)*1000, 'g');
        end
        if handles.h2.plots.Ch4 
            plot(tvec, (trace4+offset4)*1000, 'm');
        end
        xlim([0 tdt.AcqDuration]);
        ylim([-1000*offset0, 4000*offset0]);
        drawnow;
    end 
    
    % --- upclose response  
    if(handles.h2.plots.plotUpclose)
        axes(axesUpclose);
        cla; % clear fig
        hold on;
        if handles.h2.plots.Ch1 
            plot(tvec, trace1+offset1, 'b');
        end
        if handles.h2.plots.Ch2 
            plot(tvec, trace2+offset2, 'r');
        end
        if handles.h2.plots.Ch3 
            plot(tvec, trace3+offset3, 'g');
        end
        if handles.h2.plots.Ch4 
            plot(tvec, trace4+offset4, 'm');
        end
        xlim([stimulus.Delay stimulus.Delay+10]); 
        ylim([-offset0, offset0*4]);
        drawnow; 
    end

    %-------------------------------------
    % copy data to sorted storage variables
    %-------------------------------------
    fit_amp(1,stimseq(rep, trial), rep) = amp1; 
    fit_amp(2,stimseq(rep, trial), rep) = amp2; 
    fit_amp(3,stimseq(rep, trial), rep) = amp3; 
    fit_amp(4,stimseq(rep, trial), rep) = amp4; 
    fit_freq(1,stimseq(rep, trial), rep) = fq1; 
    fit_freq(2,stimseq(rep, trial), rep) = fq2; 
    fit_freq(3,stimseq(rep, trial), rep) = fq3; 
    fit_freq(4,stimseq(rep, trial), rep) = fq4; 
    fit_phi(1,stimseq(rep, trial), rep) = ph1; 
    fit_phi(2,stimseq(rep, trial), rep) = ph2; 
    fit_phi(3,stimseq(rep, trial), rep) = ph3; 
    fit_phi(4,stimseq(rep, trial), rep) = ph4;     
 
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
    % check if user pressed the Abort button
    %-------------------------------------
    cancelFlag = read_ui_val(handles.buttonAbort);

end % end of while loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the end of data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the finish time
time_end = now;

%closeTrialData(datafile, time_end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gather collected data into clickdata structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clickdata = [];
if ~cancelFlag
    clickdata.itd = clickcache.itd; % unsorted
    clickdata.itd_sort = clickcache.itd_sort; % sorted
    clickdata.fit_amp = fit_amp; % sorted
    clickdata.fit_freq = fit_freq; % sorted
    clickdata.fit_phi = fit_phi; % sorted
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
    clicksettings.dataversion = FOCHS_init('DATAVERSION');
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
    % store waveform data
    clickresp1 = resp1;
    clickresp2 = resp2;
    clickresp3 = resp3;
    clickresp4 = resp4;

    %-------------------------------------
    % save the clicksettings struct (has curve information) and 
    % the clickdata struct (has curve data spike counts but NO RAW DATA!).  
    % IMPORTANT: remember that the data in curve data are already sorted 
    %            into a [# of test values X # of reps] array (SJS)
    %-------------------------------------
    save(clicksettingsfile, '-MAT', 'clicksettings', 'clickdata', ...
                'clickresp1', 'clickresp2', 'clickresp3', 'clickresp4');

    % if succeeded then flag=1
    ClickSuccessFlag = 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot curve data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(clickdata) && ~cancelFlag

    FOCHS_clickplot(clickdata, clicksettings);

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
%       defined in HPSearch2_config()
atten = [120 120];
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));

% if aborted then reset the abort button
if cancelFlag
    update_ui_val(handles.buttonAbort,0);
end

% save handles structure 
guidata(hObject, handles);

