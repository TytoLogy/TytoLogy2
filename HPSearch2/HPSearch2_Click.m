% HPSearch2_Click.m 
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch2 "CLICK" routine.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Based on HPSearch Curve routines 
%  (HPSearch, HPCurve_buildStimCache, HPCurve_playCache): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_Click): Mar 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

disp('#### HPSearch2_Click called ###')

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
wpst = 1; % pst bin width (ms)
tpst = ( 0 : 5 : tdt.AcqDuration ); 
vpst = zeros(1, length(tpst) ); 
wisi = 0.2; % isi bin width (ms)
tisi = ( 0 : 0.2 : 10 );
visi = zeros(1, length(tisi) ); 
nspiketotal = 0;
RasterIndex = 0;
RasterLimit = analysis.Raster; % how many reps are shown

% clear plots
axesUpclose = handles.axesUpclose;
axesResp = handles.axesResp;
axesRaster = handles.axesRaster;
axesPSTH = handles.axesPSTH;
axesISIH = handles.axesISIH;
cla(axesUpclose);
cla(axesResp);
cla(axesRaster);
cla(axesPSTH);
cla(axesISIH);

% setting overwriting options
set(axesUpclose, 'NextPlot', 'replacechildren');
set(axesResp, 'NextPlot', 'replacechildren');
set(axesRaster, 'NextPlot', 'add');
set(axesPSTH, 'NextPlot', 'replacechildren');
set(axesISIH, 'NextPlot', 'replacechildren');

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
[clickfile, clickpath] = HPSearch2_buildFileName(animal, 'CLICK');
% if clickfilename == 0, user selected 'cancel',  
% so cancel the running of click and return from function
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
resp = cell(ntrials, nreps); % sorted raw data traces
spike_times = cell(ntrials, nreps); 
spike_counts = zeros(ntrials, nreps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write data file header - this will create the binary data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writeDataFileHeader2(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect spont data to adjust threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spontatten = [120, 120]; % max attenuation
handles.h2.config.setattenFunc(handles.PA5L, spontatten(L));
handles.h2.config.setattenFunc(handles.PA5R, spontatten(R));
Sn = zeros(2,ms2bin(stimulus.Duration, outFs));
[sponttrace, spontnpts, sponttraceu, spontnptsu] = ...
    handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);
if std(sponttrace) == 0
    sponttrace = 0.1*randn(size(sponttrace));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop: play sound, collect spikes, analyze data, and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize flags and counters
sindex = 0;
cancelFlag = 0;
isistr = sprintf('Starting Click\n');

% set attenuators 
% Note: the function handle 'handles.h2.config.setattenFunc' is 
%       defined in HPSearch2_config()
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
    [datatrace, npts, datatraceu, nptsu] = ...
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
	resp{stimseq(rep, trial), rep} =  datatrace';

    %-------------------------------------
    % spike detection 
    %-------------------------------------
    [spidx, th] = HPSearch2_spikedetect(datatrace, analysis.ThresSD, ...
                    ms2samples(analysis.WindowWidth, inFs), sponttrace );
    tspike = tvec(spidx); % spike timings
    nspike = sum(spidx);  % spike number 

    %-------------------------------------
    % data for histograms
    %-------------------------------------
    nspiketotal = nspiketotal + nspike;
    if nspiketotal > 1000
        vpst = zeros(1, length(tpst) ); 
        visi = zeros(1, length(tisi) ); 
        nspiketotal = 0;
    end

    %-------------------------------------
    % calculating spike rate within the entire time length
    %-------------------------------------
    a_spidx = spidx; 
    a_tspike = tvec(a_spidx); % spike timings within the analysis window
    a_nspike = sum(a_spidx);  % number of spikes within the analysis window
    a_rate = 1000 * a_nspike / (stimulus.Duration);

    % store data 
    spike_times{stimseq(rep, trial), rep} = a_tspike;
    spike_counts(stimseq(rep, trial), rep) = a_nspike;

    % show spike rate
    update_ui_str(handles.editRate, a_rate);

    %-------------------------------------
    % plotting data
    %-------------------------------------
    % --- response
    if(handles.h2.plots.plotResp)
        axes(axesResp);
        hold off; 
        plot([tvec(1) tvec(end)], [th th], 'g');
        hold on;
        plot(tvec,datatrace); 
        plot(tspike, datatrace(spidx), 'mo');
        hold off; 
        xlim([0 tdt.AcqDuration]);
        if(abs(th)>0)
            ylim( [ -2*abs(th) 2*abs(th) ] );
        end
        drawnow;
    end 
    
    % --- upclose response  
    if(handles.h2.plots.plotUpclose)
        % resizing window width
        if min(params.Freq) > 1000
            upclosewindow = [-1, 1.5];
        elseif max(params.Freq) < 100
            upclosewindow = [-10, 15];
        else 
            upclosea = round(10000/mean(params.Freq));
            if upclosea < 1
                upclosea = 1;
            elseif upclosea > 10
                upclosea = 10;
            end
            upclosewindow = [-0.1*upclosea, 0.15*upclosea]; 
        end

        axes(axesUpclose);
        hold off; 
        plot(upclosewindow, [th th], 'g'); 
        hold on;
        for j=1:nspike
            plot(tvec-tspike(j),datatrace);
        end
        hold off;
        xlim(upclosewindow);
        if(abs(th)>0)
            ylim( [ -2*abs(th) 2*abs(th) ] );
        end
        drawnow;
    end
    
    % --- raster
    if(handles.h2.plots.plotRaster)
        axes(axesRaster);
        if(RasterIndex == RasterLimit) % if reached to limit, then erase
            RasterIndex = 0;
            cla(handles.axesRaster);
        end
        hold on;
        plot(tspike, RasterIndex*ones(length(tspike)), 'b.')
        hold off;
        RasterIndex = RasterIndex+1;
        xlim([0 tdt.AcqDuration]);
        ylim([0 RasterLimit]);
        drawnow;
    end
    
    % --- ISIH 
    if(handles.h2.plots.plotISIH)
        axes(axesISIH);
        hold off;
        if nspike>=2 
            cisi= tspike(2:end) - tspike(1:end-1);
            visi = visi + hist(cisi,tisi);
        end
        bar(tisi, visi, 1)
        xlim([0 6]);
        drawnow;
    end
    
    % --- PSTH 
    if(handles.h2.plots.plotPSTH)
        axes(axesPSTH);
        hold off; 
        vpst = vpst + hist(tspike,tpst);
        bar(tpst, vpst, 1)
        xlim([0 tdt.AcqDuration]);
        drawnow;
    end

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
    clicksettings.dataversion = HPSearch2_init('DATAVERSION');
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

