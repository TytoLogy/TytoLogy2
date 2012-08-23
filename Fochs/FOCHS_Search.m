% FOCHS_Search.m
%------------------------------------------------------------------------
% 
% Script that runs the FOCHS "SEARCH" routine.
%
%------------------------------------------------------------------------
% Notes: zBUS, indev, outdev, PA5L and PA5R are assumed to be already 
% initialized when this routine is called. This means that the TDTINIT 
% status has to be checked before using this routine. 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag 
%   ashida@umd.edu
%   sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version (HPSearch_Run): 2009-2011 by SJS
% Upgraded Version (HPSearch2_Search): 2011-2012 by GA
% Four-channel Input Version (FOCHS_Search): 2012 by GA  
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting I/O parameters to TDT circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------
% Note: the function handle 'handles.h2.config.TDTsetFunc' is 
%       defined in FOCHS_config()
%-------------------------------------
Fs = handles.h2.config.TDTsetFunc(indev, outdev, tdt, stimulus, channels);

% sampling rates 
inFs = Fs(1);
outFs = Fs(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% number of points to acquire or send out
acqpts = ms2bin(tdt.AcqDuration, inFs);
outpts = ms2bin(stimulus.Duration, outFs);

% timebins for analysis
a_start = max([ ms2bin(analysis.StartTime, inFs), 1]);
a_end   = min([ ms2bin(analysis.EndTime, inFs), acqpts ]);

% time vector for plots
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
    search = FOCHS_searchParamFromUI(handles);
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
    % even if one or both channels are off, make binaural sound first,  
    % and then overwrite the silent channel with zero 

    switch upper(search.stimtype)
        case 'NOISE'
            % interpolate calibration data
            caldata = TytoLogy2_interpcal(mergedcaldata, search.Fmin, search.Fmax);
            % synthesize stimulus waveform
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
            % use merged calibration data 
            caldata = mergedcaldata;
            % synthesize stimulus waveform
            [tmpS, tmprms] = syn_headphone_tone( ...
                stimulus.Duration, outFs, search.Freq, ...
                search.ITD, stimulus.RadVary, caldata );

        case 'SAM'
            % interpolate calibration data
            caldata = TytoLogy2_interpcal(mergedcaldata, search.Fmin, search.Fmax);
            % synthesize stimulus waveform
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

        if search.LeftON && search.RightON 
            % if binaural, ABI and ILD are used 
            spl_val = computeLRspl(search.ILD, search.ABI)';
        else 
            % if monaural (or silent), only ABI is used 
            spl_val = [search.ABI search.ABI]; 
        end

        % compute attenuator settings
        % note: TytoLogy2_figure_atten() returns MAX_ATTEN if channel is off
        if ~strcmp(search.stimtype, 'SAM') % 'NOISE' or 'TONE'
               attenL = TytoLogy2_figureAtten( ...
                spl_val(L), tmprms(L), caldata.mindbspl(L), search.LeftON);
               attenR = TytoLogy2_figureAtten( ...
                spl_val(R), tmprms(R), caldata.mindbspl(R), search.RightON);
        else % 'SAM'
            attenL = TytoLogy2_figureAtten( ...
                spl_val(L), tmpmod(L), caldata.mindbspl(L), search.LeftON);
            attenR = TytoLogy2_figureAtten( ...
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
        %       defined in FOCHS_config()
        handles.h2.config.setattenFunc(handles.PA5L, attenL);
        handles.h2.config.setattenFunc(handles.PA5R, attenR);

        % store the new values
        searchold = search;

    end % end of calculating attenuation values

    %-------------------------------------
    % play the sound and return the response
    %-------------------------------------
    % Note: the function handle 'handles.h2.config.ioFunc' is 
    %       defined in FOCHS_config()
    %-------------------------------------
    [trace1, npts1, trace2, npts2, trace3, npts3, trace4, npts4] = ...
        handles.h2.config.ioFunc(S, acqpts, indev, outdev, zBUS);

    %-------------------------------------
    % start timer to measure ISI
    %-------------------------------------
    tic; 

    %-------------------------------------
    % data analysis / sine curve fitting
    %-------------------------------------
    fq0 = search.Freq;

    % resp #1 
    rvec = trace1(a_start:a_end); % response vector to be analyzed 
    [ amp1, fq1, ph1 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, search.stimtype); 
    std1 = std(rvec,1); 

    % resp #2 
    rvec = trace2(a_start:a_end); % response vector to be analyzed 
    [ amp2, fq2, ph2 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, search.stimtype); 
    std2 = std(rvec,1); 

    % resp #3 
    rvec = trace3(a_start:a_end); % response vector to be analyzed 
    [ amp3, fq3, ph3 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, search.stimtype); 
    std3 = std(rvec,1); 

    % resp #4 
    rvec = trace4(a_start:a_end); % response vector to be analyzed 
    [ amp4, fq4, ph4 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, search.stimtype); 
    std4 = std(rvec,1); 

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
    thres   = [2.5e-4, 7.5e-4, 2.5e-3, 7.5e-3, 2.5e-2, 7.5e-2, 2.5e-1, 7.5e-1, 2.5];
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
%       defined in FOCHS_config()
atten = [120 120];
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));

