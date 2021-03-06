% FOCHS_Curve.m 
%------------------------------------------------------------------------
% 
% Script that runs the FOCHS "CURVE" routine.
% 
% Present the stimulus sound over headphones, record/display 
% the recorded response, and save the data.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag 
%   ashida@umd.edu
%   sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version (HPSearch, HPCurve_buildStimCache, HPCurve_playCache): 2009-2011 by SJS
% Upgraded Version (HPSearch2_Curve): 2011-2012 by GA
% Four-channel Input Version (FOCHS_Curve): 2012 by GA  
%------------------------------------------------------------------------

% display message
str = '#### FOCHS_Curve called ###'; 
update_ui_str(handles.textMessage, str);
disp(str)

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

animal = handles.h2.animal;
curve = handles.h2.curve;
params = handles.h2.paramCurrent; 

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
acqpts = ms2samples(tdt.AcqDuration, inFs);
outpts = ms2samples(stimulus.Duration, outFs);

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
% check if calibration files have been loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch upper(handles.h2.curve.side)
    case 'BOTH'
        if ( ~handles.h2.calinfo.loadedL || ~handles.h2.calinfo.loadedR )
            errordlg('Load L and R calibration files','calibration error')
            CurveSuccessFlag = -2; % failed 
            return;
        end
        LeftON = 1;
        RightON = 1;

    case 'LEFT'
        if ~handles.h2.calinfo.loadedL 
            errordlg('Load L calibration file','calibration error')
            CurveSuccessFlag = -2; % failed 
            return;
        end
        LeftON = 1;
        RightON = 0;

    case 'RIGHT'
        if ~handles.h2.calinfo.loadedR 
            errordlg('Load R calibration file','calibration error')
            CurveSuccessFlag = -2; % failed 
            return;
        end
        LeftON = 0;
        RightON = 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check frequency range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if min(params.Freq) < handles.h2.search.limits.Freq(1)
    str = ['frequency lower limit = ' , num2str(handles.h2.search.limits.Freq(1))];
    errordlg(str, 'curve frequency range error');
    CurveSuccessFlag = -2; % failed 
    return;
end
if max(params.Freq) > handles.h2.search.limits.Freq(2)
    str = ['frequency upper limit = ' , num2str(handles.h2.search.limits.Freq(2))];
    errordlg(str, 'curve frequency range error');
    CurveSuccessFlag = -2; % failed 
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% combine two cal files into one
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mergedcaldata = TytoLogy2_mergecal( ...
    LeftON, RightON, handles.h2.caldataL, handles.h2.caldataR );  

% if noise, cutting out only the required range of the calibration data
switch upper(curve.stimtype)
    case 'NOISE'
        caldata = TytoLogy2_interpcal(mergedcaldata, min(params.Freq), max(params.Freq));
    case 'TONE'
        caldata = mergedcaldata;
end

if isempty(caldata)
    warndlg(['frequency limits = ', num2str(min(mergecaldata.Freqs)) ...
                              ' - ' num2str(max(mergecaldata.Freqs)) ]);
    CurveSuccessFlag = -2; % failed 
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check max intensity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate max achievable intensity
switch upper(curve.stimtype)
    case 'NOISE'
        Lmax = caldata.mindbspl(1);
        Rmax = caldata.mindbspl(2);
    case 'TONE'
        Lmax = min( interp1(caldata.freq, caldata.mag(1, :), params.Freq) );
        Rmax = min( interp1(caldata.freq, caldata.mag(2, :), params.Freq) );
end

% calculate desired intensity
ABImax = max(params.ABI) + max(abs(params.ILD)); 

% check if desired intensity is below the max achievable intensity 
switch upper(handles.h2.curve.side)
    case 'BOTH'
        if (ABImax>Lmax) || (ABImax>Rmax)
            warndlg(['Max intensities: Left = ', num2str(Lmax)...
                    ' dB, Right = ', num2str(Rmax) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end    
    case 'LEFT'
        if (ABImax>Lmax)
            warndlg(['Max intensity: Left = ', num2str(Lmax) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end    
    case 'RIGHT'
        if (ABImax>Rmax)
            warndlg(['Max intensity: Right = ', num2str(Rmax) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check stimulus types (tone or noise) according to curve type
switch upper(params.curvetype)

    case { 'BF', 'CF', 'CD' } % tone only with these curve types
        if strcmp(curve.stimtype, 'NOISE')
            warndlg(['Only TONE can be used with ' params.curvetype], 'stimulus type error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case { 'BC', 'SAMP', 'SAMF' } % noise only with these curve types
        if strcmp(curve.stimtype, 'TONE')
            warndlg(['Only NOISE can be used with ' params.curvetype], 'stimulus type error');
            CurveSuccessFlag = -2; % failed
            return; 
        end
end

% check stimulus sides (B/L/R) according to curve type
switch upper(params.curvetype)

    case { 'ITD', 'ILD', 'BC', 'CD' } % binaural only with these curve types
        if ~strcmp(curve.side, 'BOTH')
            warndlg(['Binaural stimulus must be used with ' params.curvetype], 'stimulus side error');
            CurveSuccessFlag = -2; % failed
            return; 
        end    

end

% if monaural, then ITD/ILD/BC parameters are ignored (reset to defaults)
switch upper(curve.side)

    case { 'LEFT', 'RIGHT' } 
        params.ITD = 0;
        params.ILD = 0;
        params.BC = 100;

end

% if noise, then Freq must be [ F(1), F(2) ] to specify upper and lower limits
% if tone, then BC/sAMp/sAMf are ignored (set to defaults)
switch upper(curve.stimtype)

    case 'NOISE' 
        if ~(length(params.Freq)==2)
            warndlg('Please specify lower and upper frequencies for NOISE', 'frequency error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'TONE'
        params.BC = 100;
        params.sAMp = 0;
        params.sAMf = 0;

end

% if not 'sAMp', 'sAMf', then sAMp/sAMf are ignored
switch upper(params.curvetype)

    case { 'SAMP', 'SAMF' } 
        % do nothing with these curve types

    otherwise 
        params.sAMp = 0;
        params.sAMf = 0;

end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine primary and secondary loop variables 
% according to the selected curve type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   e.g.: if type = 'ITD', the primary loop variable should be ITD, 
%         the secondary can be none or one of any other (BF/ABI etc)
% if more than three loop variables are set, then cast an error message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nFreq = length(params.Freq);
nITD = length(params.ITD);
nILD = length(params.ILD); 
nABI = length(params.ABI); 
nBC = length(params.BC); 
nsAMp = length(params.sAMp); 
nsAMf = length(params.sAMf); 

loopvars = {'', ''};
nloopvars = 0;

% determine the first loop variable according to the curve type
switch upper(params.curvetype)

    case 'BF' % 'TONE' only
        loopvars{1} = 'FREQ'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        if sum([ (nITD>1), (nILD>1), (nABI>1), (nBC>1) ]) > 1
            warndlg('Only one parameter in addition to Freq can be varied', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'ITD' % 'TONE' or 'NOISE'
        loopvars{1} = 'ITD'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        switch upper(curve.stimtype)
            case 'TONE'
                if sum([ (nFreq>1), (nILD>1), (nABI>1), (nBC>1) ]) > 1
                    warndlg('Only one parameter in addition to ITD can be varied', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            case 'NOISE' 
                if sum([ (nILD>1), (nABI>1), (nBC>1) ]) > 1
                    warndlg('Only one parameter in addition to ITD can be varied', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            end

    case 'ILD' % 'TONE' or 'NOISE'
        loopvars{1} = 'ILD'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        switch upper(curve.stimtype)
            case 'TONE'
                if sum([ (nFreq>1), (nITD>1), (nABI>1), (nBC>1) ]) > 1
                    warndlg('Only one parameter in addition to ILD can be varied', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            case 'NOISE' 
                if sum([ (nITD>1), (nABI>1), (nBC>1) ]) > 1
                    warndlg('Only one parameter in addition to ILD can be varied', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            end

    case 'ABI' % 'TONE' or 'NOISE'
        loopvars{1} = 'ABI'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        switch upper(curve.stimtype)
            case 'TONE'
                if sum([ (nFreq>1), (nITD>1), (nILD>1), (nBC>1) ]) > 1
                    warndlg('Only one parameter in addition to ABI can be varied', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            case 'NOISE' 
                if sum([ (nITD>1), (nILD>1), (nBC>1) ]) > 1
                    warndlg('Only one parameter in addition to ABI can be varied', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            end

    case 'BC' % 'NOISE' only
        loopvars{1} = 'BC'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        if sum([ (nITD>1), (nILD>1), (nABI>1) ]) > 1
            warndlg('Only one parameter in addition to BC can be varied', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'SAMP' % 'NOISE' only
        loopvars{1} = 'SAMP'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        if sum([ (nITD>1), (nILD>1), (nABI>1), (nsAMf>1)]) > 1
            warndlg('Only one parameter in addition to sAMp can be varied', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'SAMF' % 'NOISE' only
        loopvars{1} = 'SAMF'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        if sum([ (nITD>1), (nILD>1), (nABI>1), (nsAMp>1)]) > 1
            warndlg('Only one parameter in addition to sAMf can be varied', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'CF' % 'TONE' only
        loopvars{1} = 'FREQ'; 
        loopvars{2} = 'ABI'; 
        nloopvars = 2;
        if sum([ (nITD>1), (nILD>1) ]) > 0
            warndlg('ITD and ILD cannot be varied with CF', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'CD' % 'TONE' only
        loopvars{1} = 'ITD'; 
        loopvars{2} = 'FREQ'; 
        nloopvars = 2;
        if sum([ (nILD>1), (nABI>1) ]) > 0
            warndlg('ILD and ABI cannot be varied with CD', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return;  
        end

    case 'PH' % 'TONE' or 'NOISE'
        if (nFreq>1) 
            switch upper(curve.stimtype)
                case 'NOISE'
                    loopvars{1} = 'NONE';
                    nloopvars = 0;
                case 'TONE'
                    loopvars{1} = 'FREQ'; 
                    nloopvars = 1;
            end
        elseif (nITD>1) 
            loopvars{1} = 'ITD'; 
            nloopvars = 1;
        elseif (nILD>1) 
            loopvars{1} = 'ILD'; 
            nloopvars = 1;
        elseif (nABI>1) 
            loopvars{1} = 'ABI'; 
            nloopvars = 1;
        elseif (nBC>1) 
            loopvars{1} = 'BC'; 
            nloopvars = 1;
        elseif (nsAMp>1) 
            loopvars{1} = 'SAMP'; 
            nloopvars = 1;
        elseif (nsAMf>1) 
            loopvars{1} = 'SAMF'; 
            nloopvars = 1;
        else
            loopvars{1} = 'NONE'; 
            nloopvars = 0;
        end

        loopvars{2} = 'NONE'; 

        switch upper(curve.stimtype)
            case 'TONE'
                if sum([ (nFreq>1), (nITD>1), (nILD>1), (nABI>1), (nBC>1), (nsAMp>1), (nsAMf>1) ]) > 1
                    warndlg('Up to two parameters can be varied with PHASE', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
            case 'NOISE' 
                if sum([ (nITD>1), (nILD>1), (nABI>1), (nBC>1), (nsAMp>1), (nsAMf>1) ]) > 1
                    warndlg('Up to two parameters can be varied with PHASE', 'parameter error');
                    CurveSuccessFlag = -2; % failed
                    return; 
                end
        end
        
    otherwise 
        errordlg('error: unknown curve type', 'curve type error');
        CurveSuccessFlag = -3; % failed: fatal error
        return; 
end

if (nFreq<1) || (nITD<1) || (nILD<1) || (nABI<1) || (nBC<1) || (nsAMp<1) || (nsAMf<1)
    warndlg('Empty parameters found. Stop...', 'parameter error');
    CurveSuccessFlag = -2; % failed
    return; 
end

% determine the second loop variable 
if (nFreq>1) && ~strcmp(loopvars{1},'FREQ') && ~strcmp(curve.stimtype, 'NOISE')
    loopvars{2} = 'FREQ'; 
    nloopvars = 2;
end
if (nITD>1) && ~strcmp(loopvars{1},'ITD')
    loopvars{2} = 'ITD'; 
    nloopvars = 2;
end
if (nILD>1) && ~strcmp(loopvars{1},'ILD')
    loopvars{2} = 'ILD'; 
    nloopvars = 2;
end
if (nABI>1) && ~strcmp(loopvars{1},'ABI')
    loopvars{2} = 'ABI'; 
    nloopvars = 2;
end
if (nBC>1) && ~strcmp(loopvars{1},'BC')
    loopvars{2} = 'BC'; 
    nloopvars = 2;
end
if (nsAMp>1) && ~strcmp(loopvars{1},'SAMP')
    loopvars{2} = 'SAMP'; 
    nloopvars = 2;
end
if (nsAMf>1) && ~strcmp(loopvars{1},'SAMF')
    loopvars{2} = 'SAMF'; 
    nloopvars = 2;
end

stimcache.loopvars = loopvars;
stimcache.nloopvars = nloopvars;

% show loop variables
str = ['loop variables : ' loopvars{1} ' ' loopvars{2}];
update_ui_str(handles.textMessage, str);
disp(str)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get data/stim filename info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if curve.Temp
    disp('will save to temporary (temp.dat) file');
    % write to temp file instead
    curvepath = pwd;
    curvefilename = 'temp.dat';
    curvefile = fullfile(curvepath, curvefilename);
else 
    [curvefile, curvepath] = ...
        TytoLogy2_buildFileName(animal, params.curvetype);
    % if user selected 'cancel', then return from function
    if curvefile == 0  
        CurveSuccessFlag = -1; 
        return;
    end
end
disp(['data saved to: ' curvefile]);

% mat file to save curve results
[pathstr, filestr, extstr] = fileparts(curvefile);
curvesettingsfile = [pathstr filesep filestr '.mat'];

% if SaveStim checkbox is on, create "_stim.mat" file name
if curve.SaveStim 
    stimfile = [pathstr filesep filestr '_stim.mat'];
else
    stimfile = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a comment parameter
% this is a temporary thing, will need to create a UI for this (SJS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
animal.comments = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make stimulus cache variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of trials in each rep
if strcmp(curve.stimtype, 'TONE')
    ntrials = nFreq * nITD * nILD * nABI * nBC * nsAMp * nsAMf; 
else % if 'NOISE' then skip nFreq 
    ntrials = nITD * nILD * nABI * nBC * nsAMp * nsAMf; 
end

% if spont is used, then increase ntrials for spont 
if curve.Spont
    ntrials = ntrials + 1;
end

% total number of stimulus presentations
nreps = params.Reps;
nstims = nreps * ntrials;

% make copy of parameters and structures 
stimcache.ntrials = ntrials;
stimcache.nreps  = nreps;
stimcache.nstims = nstims;
stimcache.curvetype = params.curvetype;
stimcache.stimtype  = curve.stimtype;
stimcache.side = curve.side;
stimcache.spont = curve.Spont;
stimcache.frozen = stimulus.Frozen;
stimcache.radvary = stimulus.RadVary;

% Note: If 'FREQ' curve type is selected, then the stimulus.Frozen flag 
%       will be ignored, apparently because it is impossible to alter 
%       frequencies with stimulus fixed.
if strcmp(params.curvetype, 'FREQ')
    stimcache.frozen = 0;
end

% Note: For the same reason above, when the stimulus.Frozen flag is set, 
%       then the stimulus.RadVary flag will be ignored.
if stimcache.frozen
    stimcache.radvary = 0;
end

% set LeftON/RightON flags 
switch upper(curve.side)
    case 'BOTH'
        stimcache.LeftON = 1;
        stimcache.RightON = 1;
    case 'LEFT'
        stimcache.LeftON = 1;
        stimcache.RightON = 0;
    case 'RIGHT'
        stimcache.LeftON = 0;
        stimcache.RightON = 1;
end

% make arrays/cells to store temporary (unrandomized) variables
tempcache.Freq = cell(ntrials, 1);
tempcache.ITD = zeros(ntrials, 1);
tempcache.ILD = zeros(ntrials, 1);
tempcache.ABI = zeros(ntrials, 1);
tempcache.BC = zeros(ntrials, 1);
tempcache.sAMp = zeros(ntrials, 1);
tempcache.sAMf = zeros(ntrials, 1);
tempcache.isspont = zeros(ntrials, 1);

% make arrays/cells to store variables
stimcache.rep = zeros(nstims, 1);
stimcache.Freq = cell(nstims, 1);
stimcache.ITD = zeros(nstims, 1);
stimcache.ILD = zeros(nstims, 1);
stimcache.ABI = zeros(nstims, 1);
stimcache.BC = zeros(nstims, 1);
stimcache.sAMp = zeros(nstims, 1);
stimcache.sAMf = zeros(nstims, 1);
stimcache.isspont = zeros(nstims, 1);

% make cells to store stimulus
stimcache.Sn = cell(nstims, 1);
stimcache.splval = cell(nstims, 1);
stimcache.rmsval = cell(nstims, 1);
stimcache.atten = cell(nstims, 1);

% time vector (in ms)
stimcache.tvec = (0:ms2bin(stimulus.Duration, outFs)-1) * 1000 / outFs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make parameter sets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sindex = 0;

% --- loops for parameters
for isAMf = 1:nsAMf
for isAMp = 1:nsAMp 
for iBC = 1:nBC
for iABI = 1:nABI
for iILD = 1:nILD
for iITD = 1:nITD

if strcmp(curve.stimtype, 'TONE') 
% if 'TONE' is used, then Freq is one of the loop variables
for iFreq = 1:nFreq
    sindex = sindex + 1;
    tempcache.Freq{sindex}  = params.Freq(iFreq);
    tempcache.ITD(sindex) = params.ITD(iITD);
    tempcache.ILD(sindex) = params.ILD(iILD);
    tempcache.ABI(sindex) = params.ABI(iABI);
    tempcache.BC(sindex)  = params.BC(iBC);
    tempcache.sAMp(sindex)  = params.sAMp(isAMp);
    tempcache.sAMf(sindex)  = params.sAMf(isAMf);
end % end of Freq loop

else 
% if 'NOISE' is used, then Freq indicates lower and upper freqs for noise
    sindex = sindex + 1;
    tempcache.Freq{sindex}  = [ params.Freq(1) params.Freq(2) ];
    tempcache.ITD(sindex) = params.ITD(iITD);
    tempcache.ILD(sindex) = params.ILD(iILD);
    tempcache.ABI(sindex) = params.ABI(iABI);
    tempcache.BC(sindex)  = params.BC(iBC);
    tempcache.sAMp(sindex)  = params.sAMp(isAMp);
    tempcache.sAMf(sindex)  = params.sAMf(isAMf);
end

end % end of ITD loop
end % end of ILD loop
end % end of ABI loop
end % end of BC loop
end % end of sAMp loop
end % end of sAMf loop
% --- end of the loops

% make spont
if curve.Spont
    sindex = sindex + 1; 
    tempcache.Freq{sindex} = -99999; 
    tempcache.ITD(sindex) = -99999;
    tempcache.ILD(sindex) = -99999;
    tempcache.ABI(sindex) = -99999;
    tempcache.BC(sindex)  = -99999;
    tempcache.sAMp(sindex) = -99999;
    tempcache.sAMf(sindex) = -99999;
    tempcache.isspont(sindex) = 1; % flag for spont 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomize trial presentations
% --- source from HPCurve_randomSequence by SJS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stimseq = zeros(nreps, ntrials);
for ireps = 1:nreps
    stimseq(ireps, :) = randperm(ntrials);
end
% store to stimcache
stimcache.trialRandomSequence = stimseq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set loop variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rep and trial numbers 
repnum = zeros(nstims, 1);
trialnum = zeros(nstims, 1);

sindex = 0;
for ireps = 1:nreps
    for itrials = 1:ntrials
        sindex = sindex + 1;
        repnum(sindex) = ireps;
        trialnum(sindex) = itrials;
    end
end

% loop variables
stimcache.loopvar = zeros(nstims, 2);

for i = 1:2
sindex = 0;
for ireps = 1:nreps
    for itrials = 1:ntrials
        sindex = sindex + 1;

        % Note:: tmpcache: sorted, stimcache: randomized
        switch loopvars{i}
        case 'FREQ'
            stimcache.loopvar(sindex,i) = tempcache.Freq{stimseq(ireps,itrials)};
        case 'ITD'
            stimcache.loopvar(sindex,i) = tempcache.ITD(stimseq(ireps,itrials)); 
        case 'ILD'
            stimcache.loopvar(sindex,i) = tempcache.ILD(stimseq(ireps,itrials));  
        case 'ABI'
            stimcache.loopvar(sindex,i) = tempcache.ABI(stimseq(ireps,itrials)); 
        case 'BC'
            stimcache.loopvar(sindex,i) = tempcache.BC(stimseq(ireps,itrials)); 
        case 'SAMP'
            stimcache.loopvar(sindex,i) = tempcache.sAMp(stimseq(ireps,itrials)); 
        case 'SAMF'
            stimcache.loopvar(sindex,i) = tempcache.sAMf(stimseq(ireps,itrials)); 
        case 'NONE' 
            stimcache.loopvar(sindex,i) = NaN;
        otherwise 
            disp('something is wrong with loopvar settings');
            CurveSuccessFlag = -1; 
            return;
        end

    end
end
end

% dependent variables
stimcache.depvars      = zeros(ntrials, nreps, 2);
stimcache.depvars_sort = zeros(ntrials, nreps, 2);

for sindex = 1:nstims
    rep   = repnum(sindex);
    trial = trialnum(sindex);
    stimcache.depvars(trial, rep, :) = stimcache.loopvar(sindex, :);
    stimcache.depvars_sort(stimseq(rep, trial), rep, :) = stimcache.loopvar(sindex, :);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make stimulus cache 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------
% if stimulus is frozen, generate zero ITD spectrum or tone
%---------------------------------------------------------
if stimcache.frozen
    switch upper(params.curvetype)

    case { 'SAMP', 'SAMF' } % for amplitude modulated noise
    % get Smag and Sphase, using ITD=0, sAMp=50, sAMf=10, AMphi=0  (dummy data)
        [S0, Scale0, ScaleMod0, ModPhi0, Smag0, Sphase0] = ...
            syn_headphone_amnoise(stimulus.Duration, outFs, ...
                tempcache.Freq{1}, 0, tempcache.BC(1), 50, 10, 0, caldata);

    otherwise % for regular noise or tone
        switch upper(curve.stimtype)
            case 'NOISE'
            % get Smag and Sphase, using ITD=0 
            [S0, Scale0, Smag0, Sphase0] = ...
            syn_headphone_noise(stimulus.Duration, outFs, ...
                tempcache.Freq{1}(1), tempcache.Freq{1}(2), 0, tempcache.BC(1), caldata);
            case 'TONE' % use ITD=0 
            [S0, Scale0] = syn_headphone_tone(stimulus.Duration, outFs,... 
                 tempcache.Freq{1}(1), 0, 0, caldata);            
        end
    end
end

%---------------------------------------------------------
% now loop through the randomized trials
%---------------------------------------------------------

sindex = 0;
for ireps = 1:nreps
    for itrials = 1:ntrials
        sindex = sindex + 1;

        % get parameters from tempcache 
        tmpfreq = tempcache.Freq{stimseq(ireps,itrials)};
        tmpITD = tempcache.ITD(stimseq(ireps,itrials));
        tmpILD = tempcache.ILD(stimseq(ireps,itrials));
        tmpABI = tempcache.ABI(stimseq(ireps,itrials));
        tmpBC  = tempcache.BC(stimseq(ireps,itrials));
        tmpsAMp = tempcache.sAMp(stimseq(ireps,itrials));
        tmpsAMf = tempcache.sAMf(stimseq(ireps,itrials));
        tmpisspont = tempcache.isspont(stimseq(ireps,itrials));

    if tmpisspont % if spont, make zero stimulus
        Sn = zeros(2,ms2bin(stimulus.Duration, outFs));
        rmsval = 0;
        spl_val = [-120; -120]; 
        atten = [120, 120]; % max attenuation

    else % not spont

        % synthesize sound
        if stimcache.frozen % if stimulus is frozen

            switch upper(params.curvetype)
            case { 'SAMP', 'SAMF' } % for amplitude modulated noise
                [Sn, rmsval, rms_mod, modPhi] = ...
                    syn_headphone_amnoise(stimulus.Duration, outFs, ...
                        tmpfreq, tmpITD, tmpBC, tmpsAMp, tmpsAMf, 0, ...
                        caldata, Smag0, Sphase0);

            otherwise % for regular noise or tone
                switch upper(curve.stimtype)
                case 'NOISE'
                    [Sn, rmsval] = syn_headphone_noise(stimulus.Duration, outFs, ...
                        tmpfreq(1), tmpfreq(2), tmpITD, tmpBC, caldata, Smag0, Sphase0);
                case 'TONE' % enforce radvary = 0
                    [Sn, rmsval] = syn_headphone_tone(stimulus.Duration, outFs,...
                         tmpfreq, tmpITD, 0, caldata);
                end

            end 

        else % stimulus is not frozen

            switch upper(params.curvetype)
            case { 'SAMP', 'SAMF' } % for amplitude modulated noise
                [Sn, rmsval, rms_mod, modPhi] = ...
                    syn_headphone_amnoise(stimulus.Duration, outFs, ...
                        tmpfreq, tmpITD, tmpBC, tmpsAMp, tmpsAMf, [], caldata);

            otherwise % for regular noise or tone
                switch upper(curve.stimtype)
                case 'NOISE'
                    [Sn, rmsval] = syn_headphone_noise(stimulus.Duration, outFs, ...
                        tmpfreq(1), tmpfreq(2), tmpITD, tmpBC, caldata);

                case 'TONE' 
                    [Sn, rmsval] = syn_headphone_tone(stimulus.Duration, outFs,...
                         tmpfreq, tmpITD, stimcache.radvary, caldata);

                end

            end 

        end % end of if stimulus.Frozen
        % ramp the sound on and off (important!)
        Sn = sin2array(Sn, stimulus.Ramp, outFs);

        % set zero to channels that are off
        Sn(L,:) = Sn(L,:) * stimcache.LeftON; 
        Sn(R,:) = Sn(R,:) * stimcache.RightON; 

        % calculate the L and R channel db levels 
        spl_val = computeLRspl(tmpILD, tmpABI);

        % get the attenuator settings for the desired SPL
        switch upper(params.curvetype)
        case { 'SAMP', 'SAMF' } % for amplitude modulated noise
            attenL = TytoLogy2_figureAtten( ...
                spl_val(L), rms_mod(L), caldata.mindbspl(L), stimcache.LeftON);
            attenR = TytoLogy2_figureAtten( ...
                spl_val(R), rms_mod(R), caldata.mindbspl(R), stimcache.RightON); 
        otherwise % regular noise or tone
            attenL = TytoLogy2_figureAtten( ...
                spl_val(L), rmsval(L), caldata.mindbspl(L), stimcache.LeftON);
            attenR = TytoLogy2_figureAtten( ...
                spl_val(R), rmsval(R), caldata.mindbspl(R), stimcache.RightON);    
        end
        atten = [ attenL, attenR ];

    end 

    % Store the parameters in the stimulus cache struct
    stimcache.Sn{sindex} = Sn;
    stimcache.splval{sindex} = spl_val;
    stimcache.atten{sindex} = atten;
    switch upper(params.curvetype)
        case { 'SAMP', 'SAMF' } % for amplitude modulated noise
            stimcache.rmsval{sindex} = rms_mod;
        otherwise
            stimcache.rmsval{sindex} = rmsval;
    end

    % Store the parameters in the stimulus cache struct
    stimcache.rep(sindex) = ireps;
    stimcache.Freq{sindex} = tmpfreq;
    stimcache.ITD(sindex) = tmpITD;
    stimcache.ILD(sindex) = tmpILD;
    stimcache.ABI(sindex) = tmpABI;
    stimcache.BC(sindex) = tmpBC;
    stimcache.sAMp(sindex) = tmpsAMp;
    stimcache.sAMf(sindex) = tmpsAMf;
    stimcache.isspont(sindex) = tmpisspont;

    end % end of trials loop
end % end of reps loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save stimulus cache as a mat file if saveStim is selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if curve.SaveStim
    disp(['Writing stimulus cache to MAT file ' stimfile])
    save(stimfile, 'stimcache', 'caldata', '-MAT')
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
isspont = zeros(ntrials, nreps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write data file header - this will create the binary data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writeDataFileHeader2(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect spont data (to be used as reference)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% atten = [120, 120]; % max attenuation
% handles.h2.config.setattenFunc(handles.PA5L, atten(L));
% handles.h2.config.setattenFunc(handles.PA5R, atten(R));
% Sn = zeros(2,ms2bin(stimulus.Duration, outFs));
% [sponttrace1, spontnpts1, sponttrace2, spontnpts2, ...
%  sponttrace3, spontnpts3, sponttrace4, spontnpts4] = ...
%     handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);
% if std(sponttrace) == 0
%     sponttrace = 5*randn(size(sponttrace));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop: play sound, collect spikes, analyze data, and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize flags and counters
sindex = 0;
cancelFlag = 0;
isistr = sprintf('Starting Curve\n');

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
    if stimcache.isspont(sindex) 
        str1 = sprintf('SPONT');
        str2 = sprintf('\n');
    else
        if strcmp(loopvars{1}, 'NONE')
            str1 = '';
        else
            str1 = sprintf('%s = %.0f', lower(loopvars{1}), stimcache.loopvar(sindex,1));
        end
        if strcmp(loopvars{2}, 'NONE')
            str2 = '';
        else
            str2 = sprintf(',  %s = %.0f\n', lower(loopvars{2}), stimcache.loopvar(sindex,2));
        end
    end

    update_ui_str(handles.textMessage, [ isistr str0 str1 str2 ]);

    %-------------------------------------
    % set the attenuators
    %-------------------------------------
    % get the attenuator values
    atten = stimcache.atten{sindex};

    %-------------------------------------
    % Note: the function handle 'handles.h2.config.setattenFunc' is 
    %       defined in FOCHS_config()
    %-------------------------------------
    handles.h2.config.setattenFunc(handles.PA5L, atten(L));
    handles.h2.config.setattenFunc(handles.PA5R, atten(R));

    %-------------------------------------
    % now play the sound and return the response
    % Note: the function handle 'handles.h2.config.ioFunc' is 
    %       defined in FOCHS_config()
    %-------------------------------------
    % get the stimulus waveform 
    Sn = stimcache.Sn{sindex};

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
    fq0 = max([ mean(stimcache.Freq{sindex}), 0 ]);

    % resp #1 
    rvec = trace1(a_start:a_end); % response vector to be analyzed 
    [ amp1, fq1, ph1 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, curve.stimtype); 
    std1 = std(rvec,1); 

    % resp #2 
    rvec = trace2(a_start:a_end); % response vector to be analyzed 
    [ amp2, fq2, ph2 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, curve.stimtype); 
    std2 = std(rvec,1); 

    % resp #3 
    rvec = trace3(a_start:a_end); % response vector to be analyzed 
    [ amp3, fq3, ph3 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, curve.stimtype); 
    std3 = std(rvec,1); 

    % resp #4 
    rvec = trace4(a_start:a_end); % response vector to be analyzed 
    [ amp4, fq4, ph4 ] = ... 
        FOCHS_cosfit(rvec, fq0, inFs, curve.stimtype); 
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
    isspont(stimseq(rep, trial), rep) = stimcache.isspont(sindex);

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
% gather collected data into curvedata structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curvedata = [];
if ~cancelFlag
    curvedata.depvars = stimcache.depvars; % unsorted
    curvedata.depvars_sort = stimcache.depvars_sort; % sorted
    curvedata.fit_amp = fit_amp; % sorted
    curvedata.fit_freq = fit_freq; % sorted
    curvedata.fit_phi = fit_phi; % sorted
    curvedata.isspont = isspont; % sorted
    if curve.SaveStim
        curvedata.stimfile = stimfile;
    end
end
% save cancel flag status in curvedata
curvedata.cancelFlag = cancelFlag;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save curve data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(curvedata) && ~cancelFlag

    % store start and stop times and data version
    curvesettings.time_start = datestr(time_start);
    curvesettings.time_stop = datestr(time_end);
    curvesettings.dataversion = FOCHS_init('DATAVERSION');
    curvesettings.curvesettingsfile = curvesettingsfile;
    % store various settings structs to curvesetting
    curvesettings.stim = stimulus;
    curvesettings.tdt = tdt;
    curvesettings.channels = channels;
    curvesettings.analysis = analysis;
    curvesettings.animal = animal;
    curvesettings.caldata = caldata;
    curvesettings.curve = curve;
    curvesettings.Fs = Fs;
    % remove the stimulus traces from the stimcache and add to curvesettings struct
    curvesettings.stimcache = rmfield(stimcache, 'Sn');
    % store waveform data
    curveresp1 = resp1;
    curveresp2 = resp2;
    curveresp3 = resp3;
    curveresp4 = resp4;

    %-------------------------------------
    % save the curvesettings struct (has curve information) and 
    % the curvedata struct (has curve data spike counts but NO RAW DATA!).  
    % IMPORTANT: remember that the data in curve data are already sorted 
    %            into a [# of test values X # of reps] array (SJS)
    %-------------------------------------    
    save(curvesettingsfile, '-MAT', 'curvesettings', 'curvedata', ...
               'curveresp1', 'curveresp2', 'curveresp3', 'curveresp4');

    % if succeeded then flag=1
    CurveSuccessFlag = 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot curve data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(curvedata) && ~cancelFlag

    FOCHS_simpleplot(curvedata, curvesettings);

else

    if cancelFlag
        update_ui_str(handles.textMessage, 'Curve Aborted');
        disp('Aborted');
    else
        warndlg('Error in running Curve.'); 
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some cleanup before exit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% before exit, set the attenuator to max attenuation  
% Note: the function handle 'handles.h2.config.setattenFunc' is 
%       defined in FOCHS_config()
atten = [120 120];
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));

% if aborted then reset the abort button
if cancelFlag
    update_ui_val(handles.buttonAbort,0);
end

% save handles structure 
guidata(hObject, handles);

