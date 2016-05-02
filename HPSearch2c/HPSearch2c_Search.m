% HPSearch2c_Search.m
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch2c "SEARCH" routine.
%
%------------------------------------------------------------------------
% Notes: zBUS, indev, outdev, PA5L and PA5R are assumed to be already 
% initialized when this routine is called. This means that the TDTINIT 
% status has to be checked before using this routine. 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida, Felix Dollack & Sharad Shanbhag 
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch_Run): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_Search): 2011-2012 by GA
% Adopted for HPSearch2a (HPSearch2a_Search): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_Search): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_Search): Jan 2015 by GA
%  --- code for AM tone has been added 
% Adopted for HPSearch2c (HPSearch2c_Search): Jan 2015 by FD
%  functionality for AM tone has been added 
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preliminary settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 1;
R = 2;
MAXATTEN = 120;
MINATTEN = 0;

% make some local copies of config structs to simplify
indev = handles.indev;
outdev = handles.outdev;
zBUS = handles.zBUS;
tdt = handles.h2.tdt;
stimulus = handles.h2.stimulus;
channels = handles.h2.channels;
analysis = handles.h2.analysis;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting I/O parameters to TDT circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------
% Note: the function handle 'handles.h2.config.TDTsetFunc' is 
%       defined in HPSearch2c_config()
%-------------------------------------
Fs = handles.h2.config.TDTsetFunc(indev, outdev, tdt, stimulus, channels);

% sampling rates 
inFs = Fs(1);
outFs = Fs(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% number of points to acquire or send out
acqpts = ms2samples(tdt.AcqDuration, inFs);
outpts = ms2samples(stimulus.Duration, outFs);

% some vectors for plots
tvec = 1000*(0:acqpts-1)/inFs; % (ms)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main part: play sound, collect spikes, analyze data, and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% new stimulus, so set the flag 
newstimFlag = 1;
% counter for # of stims
stimulusCount = 0;
% store 'old' parameters
searchold = handles.h2.search;

while read_ui_val(hObject)  % loop while Search button is on

    % get updated search parameters
    search = HPSearch2c_searchParamFromUI(handles);
    % check to see if the stimulus has changed 
    newstimFlag = ~isequal(searchold, search) || stimulusCount==0; 

    %-------------------------------------
    % merge L and R calibration data -- combine two cal files into one
    %-------------------------------------
    % mergedcaldata has to be re-calculated before sound generation
    % whenever newstimFlag is set
    if newstimFlag
        mergedcaldata = TytoLogy2_mergecal( ...
            search.LeftON, search.RightON, ...
            handles.h2.caldataL, handles.h2.caldataR ); 
    end

    %-------------------------------------
    % synthesize stimulus sound 
    %-------------------------------------
    % even if one or both channels are off, make binaural sound anyway. 
    switch upper(search.stimtype)
        case 'NOISE'
            caldata = TytoLogy2_interpcal(mergedcaldata, search.Fmin, search.Fmax);
            if ~handles.h2.stimulus.Frozen || newstimFlag % generate new noise
                [tmpS, tmprms, noisemag, noisephase] = syn_headphone_noise( ...
                    stimulus.Duration, outFs, search.Fmin, search.Fmax, ...
                    search.ITD, search.BC, caldata );
            else % handles.h2.stimulus.Frozen = 1 --- use old noise
                [tmpS, tmprms, noisemag, noisephase] = syn_headphone_noise( ...
                    stimulus.Duration, outFs, search.Fmin, search.Fmax, ...
                    search.ITD, search.BC, caldata, noisemag, noisephase );
            end  

        case 'TONE'
            caldata = mergedcaldata;
            [tmpS, tmprms] = syn_headphone_tone( ...
                stimulus.Duration, outFs, search.Freq, ...
                search.ITD, stimulus.RadVary, caldata );

        case 'AMNOISE'
            caldata = TytoLogy2_interpcal(mergedcaldata, search.Fmin, search.Fmax);
            [tmpS, tmprms, tmpmod, tmpphi] = syn_headphone_amnoise( ...
                stimulus.Duration, outFs, [search.Fmin search.Fmax], ...
                search.ITD, search.BC, search.sAMp, search.sAMf, [], caldata);

        case 'AMTONE'
            caldata = mergedcaldata;
            [tmpS, tmpmod, tmpphi] = syn_headphone_amtone( ...
                stimulus.Duration, outFs, search.Freq, ...
                search.ITD, search.sAMp, search.sAMf, [], stimulus.RadVary, caldata );
    end

    % set zero to channels that are off
    S(L,:) = tmpS(L,:) * search.LeftON; 
    S(R,:) = tmpS(R,:) * search.RightON; 

    % apply the sin^2 amplitude envelope to the stimulus
    S = sin2array(S, stimulus.Ramp, outFs);

    %-------------------------------------
    % if new stimulus, then attenuator levels need to be re-computed 
    %-------------------------------------
    if newstimFlag

        if search.LeftON && search.RightON % if binaural, ABI and ILD are used
            spl_val = computeLRspl(search.ILD, search.ABI)';
        else  % if monaural (or silent), only ABI is used
            spl_val = [search.ABI search.ABI];
        end
        
        % get rms value from synthesized waveform
        if( strcmp(search.stimtype, 'AMNOISE') || strcmp(search.stimtype, 'AMTONE'))
            tmpr = tmpmod;
        else % 'NOISE' or 'TONE' 
            tmpr = tmprms;
        end

        % compute attenuator settings
        % note: TytoLogy2_figure_atten() returns MAX_ATTEN if channel is off
       	attenL = TytoLogy2_figureAtten( ...
            spl_val(L), tmpr(L), caldata.mindbspl(L), search.LeftON);
       	attenR = TytoLogy2_figureAtten( ...
            spl_val(R), tmpr(R), caldata.mindbspl(R), search.RightON);

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

        % update stim struct from computed atten values
        search.Latt = attenL;
        search.Ratt = attenR;

        % update the controls (editboxes and sliders) for attenuators
        control_update(handles.editLatt, handles.sliderLatt, attenL );
        control_update(handles.editRatt, handles.sliderRatt, attenR );

        % set the attenuators
        % Note: the function handle 'handles.h2.config.setattenFunc' is 
        %       defined in HPSearch2c_config()
        handles.h2.config.setattenFunc(handles.PA5L, attenL);
        handles.h2.config.setattenFunc(handles.PA5R, attenR);

		% store the new values
        searchold = search;

    end % end of calculating attenuation values

    %-------------------------------------
    % play the sound and return the response
    %-------------------------------------
    % Note: the function handle 'handles.h2.config.ioFunc' is 
    %       defined in HPSearch2c_config()
    %-------------------------------------
    [datatrace, npts, datatraceu, nptsu] = ...
        handles.h2.config.ioFunc(S, acqpts, indev, outdev, zBUS);

    %-------------------------------------
    % start timer to measure ISI
    %-------------------------------------
    tic; 

    %-------------------------------------
    % reading analysis/plotting settings from UI
    %-------------------------------------
    plotparams = HPSearch2c_plotParamFromUI(handles);

    %-------------------------------------
    % determine threshold
    %-------------------------------------
    if plotparams.ThAuto  % if automatic threshold 
        % use spontaneous response as reference 
        refleng = max([ ms2samples(stimulus.Delay, inFs), 2 ]);
        refresp = datatrace(1:refleng-1);
        % calulate threshold
        refSD = std(refresp);
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

    % showing spike rate within the analysis window 
    a_start = ms2samples(analysis.StartTime, inFs);  
    a_end   = ms2samples(analysis.EndTime, inFs); 
    a_idx = [ zeros(1,a_start) ones(1,a_end-a_start), zeros(1,length(spidx)-a_end) ]; 
    a_nspike = sum( spidx & a_idx(1:length(spidx)) );
    a_rate = 1000 * a_nspike / (analysis.EndTime-analysis.StartTime);
    update_ui_str(handles.editRate, a_rate);

    %-------------------------------------
    % plotting data
    %-------------------------------------
    % frequency info used for plots
    plotparams.minfreq = search.Freq; 
    plotparams.maxfreq = search.Freq;

    % call plotting script
    HPSearch2c_plotResponse;

    % flush buffer
%     drawnow; %% makes it very SLOW (by FD)
%     pause( 0.01 ); % results in about 190 ms instead of 10 ms :D

    %-------------------------------------
    % pause for ISI
    %-------------------------------------
    elapsed_sec = toc;     % stop timer
%     disp( elapsed_sec )
    isi_sec = stimulus.ISI/1000;
    if elapsed_sec < isi_sec;
        pause(isi_sec - elapsed_sec); 
    end
    str = ['ISI = ' num2str(max([elapsed_sec,isi_sec])) ' sec'];
    update_ui_str(handles.textMessage, str); 

    % increment counter
    stimulusCount = stimulusCount + 1;

end % end of while loop

% before exit, set the attenuator to max attenuation  
% Note: the function handle 'handles.h2.config.setattenFunc' is 
%       defined in HPSearch2c_config()
atten = [MAXATTEN MAXATTEN];
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));
