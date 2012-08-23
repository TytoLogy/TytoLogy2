% HPSearch2_Search.m
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch2 "SEARCH" routine.
%
%------------------------------------------------------------------------
% Notes: zBUS, indev, outdev, PA5L and PA5R are assumed to be already 
% initialized when this routine is called. This means that the TDTINIT 
% status has to be checked before using this routine. 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag 
%   ashida@umd.edu
%    sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch_Run): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_Search): 2011-2012 by GA
%
% Revisions: 
%
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preliminary settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 1;
R = 2;

% make some local copies of config structs to simplify
indev = handles.indev;
outdev = handles.outdev;
zBUS = handles.zBUS;
tdt = handles.h2.tdt;
stimulus = handles.h2.stimulus;
channels = handles.h2.channels;
analysis = handles.h2.analysis;

% combine two cal files into one
mergedcaldata = HPSearch2_mergecal( ...
    handles.h2.search.LeftON, handles.h2.search.RightON, ...
    handles.h2.caldataL, handles.h2.caldataR );  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting I/O parameters to TDT circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------
% Note: the function handle 'handles.h2.config.TDTsetFunc' is 
%       defined in HPSearch2_config()
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
    search = HPSearch2_searchParamFromUI(handles);
    % check to see if the stimulus has changed 
    newstimFlag = ~isequal(searchold, search) || stimulusCount==0; 

    %-------------------------------------
    % synthesize stimulus sound 
    %-------------------------------------
    % even if one or both channels are off, make binaural sound anyway. 
    switch upper(search.stimtype)
        case 'NOISE'
            caldata = HPSearch2_interpcal(mergedcaldata, search.Fmin, search.Fmax);
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

        case 'SAM'
            caldata = HPSearch2_interpcal(mergedcaldata, search.Fmin, search.Fmax);
            [tmpS, tmprms, tmpmod, tmpphi] = syn_headphone_amnoise( ...
                stimulus.Duration, outFs, [search.Fmin search.Fmax], ...
                search.ITD, search.BC, search.sAMp, search.sAMf, [], caldata);
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

        % compute attenuator settings
        % note: HPSearch2_figure_atten() returns MAX_ATTEN if channel is off
        if ~strcmp(search.stimtype, 'SAM') % 'NOISE' or 'TONE'
           	attenL = HPSearch2_figureAtten( ...
                spl_val(L), tmprms(L), caldata.mindbspl(L), search.LeftON);
           	attenR = HPSearch2_figureAtten( ...
                spl_val(R), tmprms(R), caldata.mindbspl(R), search.RightON);
        else % 'SAM'
            attenL = HPSearch2_figureAtten( ...
                spl_val(L), tmpmod(L), caldata.mindbspl(L), search.LeftON);
            attenR = HPSearch2_figureAtten( ...
                spl_val(R), tmpmod(R), caldata.mindbspl(R), search.RightON);
        end

        % update stim struct from computed atten values
        search.Latt = attenL;
        search.Ratt = attenR;

        % update the controls (editboxes and sliders) for attenuators
        control_update(handles.editLatt, handles.sliderLatt, attenL );
        control_update(handles.editRatt, handles.sliderRatt, attenR );

        % set the attenuators
        % Note: the function handle 'handles.h2.config.setattenFunc' is 
        %       defined in HPSearch2_config()
        handles.h2.config.setattenFunc(handles.PA5L, attenL);
        handles.h2.config.setattenFunc(handles.PA5R, attenR);

		% store the new values
        searchold = search;

    end % end of calculating attenuation values

    %-------------------------------------
    % play the sound and return the response
    %-------------------------------------
    % Note: the function handle 'handles.h2.config.ioFunc' is 
    %       defined in HPSearch2_config()
    %-------------------------------------
    [resp, npts, respu, nptsu] = ...
        handles.h2.config.ioFunc(S, acqpts, indev, outdev, zBUS);

    %-------------------------------------
    % start timer to measure ISI
    %-------------------------------------
    tic; 

    %-------------------------------------
    % spike detection 
    %-------------------------------------
    [spidx, th] = HPSearch2_spikedetect(...
        resp, analysis.ThresSD, ms2samples(analysis.WindowWidth, inFs) );
    tspike = tvec(spidx); % spike timings
    nspike = sum(spidx);  % spike number 
    nspiketotal = nspiketotal + nspike;
    if nspiketotal>1000
        vpst = zeros(1, length(tpst) ); 
        visi = zeros(1, length(tisi) ); 
        nspiketotal = 0;
    end
    % showing spike rate
    a_start = ms2samples(analysis.StartTime, inFs);  
    a_end   = ms2samples(analysis.EndTime, inFs); 
    a_idx = [ zeros(1,a_start) ones(1,a_end-a_start), zeros(1,length(spidx)-a_end) ]; 
    a_nspikes = sum( spidx & a_idx(1:length(spidx)) );
    a_rate = 1000 * a_nspikes / (analysis.EndTime-analysis.StartTime);
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
        plot(tvec,resp); 
        plot(tspike, resp(spidx), 'mo');
        hold off; 
        xlim([0 tdt.AcqDuration]);
        if(abs(th)>0)
            ylim( [ -2*abs(th) 2*abs(th) ] );
        end
    end 
    
    % --- upclose response  
    if(handles.h2.plots.plotUpclose)
        if search.Freq > 1000
            upclosewindow = [-1, 1.5];
        elseif search.Freq < 100
            upclosewindow = [-10, 15];
        else 
            upclosea = round(10000/search.Freq);
            upclosewindow = [-0.1*upclosea, 0.15*upclosea]; 
        end

        axes(axesUpclose);
        hold off; 
        plot(upclosewindow, [th th], 'g'); 
        hold on;
        for j=1:nspike
            plot(tvec-tspike(j),resp);
        end
        hold off;
        xlim(upclosewindow);
        if(abs(th)>0)
            ylim( [ -2*abs(th) 2*abs(th) ] );
        end
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
    end
    
    % --- PSTH 
    if(handles.h2.plots.plotPSTH)
        axes(axesPSTH);
        hold off; 
        vpst = vpst + hist(tspike,tpst);
        bar(tpst, vpst, 1)
        xlim([0 tdt.AcqDuration]);
    end

    %-------------------------------------
    % pause for ISI
    %-------------------------------------
    elapsed_sec = toc;     % stop timer 
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
%       defined in HPSearch2_config()
atten = [120 120];
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));
