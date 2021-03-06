% HPSearch2c_Curve.m 
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch2c "CURVE" routine.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida, Felix Dollack & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written 
%   (HPSearch, HPCurve_buildStimCache, HPCurve_playCache): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_Curve): 2011-2012 by GA
% Adopted for HPSearch2a (HPSearch2a_Curve): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_Curve): Nov 2012 by GA
%  --- FILD has been implemented 
% Adopted for HPSearch2c (HPSearch2c_Curve): Jan 2015 by GA
%  --- code for AM tone has been added 
%------------------------------------------------------------------------

disp('#### HPSearch2_Curve called ###')

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
animal = handles.h2.animal;
curve = handles.h2.curve;
params = handles.h2.paramCurrent; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting I/O parameters to TDT circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set TDT
Fs = handles.h2.config.TDTsetFunc(indev, outdev, tdt, stimulus, channels);

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
nspikelimit = 10000;
rasterindex = 0;
rasterlimit = analysis.Raster; % how many reps are shown

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
% check if calibration files have been loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch upper(handles.h2.curve.side)
    case 'BOTH'
        if ( ~handles.h2.calinfo.loadedL || ~handles.h2.calinfo.loadedR )
            warndlg('Load L and R calibration files','calibration error')
            CurveSuccessFlag = -2; % failed 
            return;
        end
        LeftON = 1;
        RightON = 1;

    case 'LEFT'
        if ~handles.h2.calinfo.loadedL 
            warndlg('Load L calibration file','calibration error')
            CurveSuccessFlag = -2; % failed 
            return;
        end
        LeftON = 1;
        RightON = 0;

    case 'RIGHT'
        if ~handles.h2.calinfo.loadedR 
            warndlg('Load R calibration file','calibration error')
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
    warndlg(str, 'curve frequency range error');
    CurveSuccessFlag = -2; % failed 
    return;
end
if max(params.Freq) > handles.h2.search.limits.Freq(2)
    str = ['frequency upper limit = ' , num2str(handles.h2.search.limits.Freq(2))];
    warndlg(str, 'curve frequency range error');
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

% calculate max desired intensity
switch upper(curve.side)
    case { 'LEFT', 'RIGHT' } 
        ABImaxL = max(params.ABI);
        ABImaxR = max(params.ABI);
    case 'BOTH'
        switch upper(params.curvetype)
            case 'FILDL' 
                ABImaxL = max(params.ABI);
                ABImaxR = max(params.ABI) + max(params.ILD);
            case 'FILDR'
                ABImaxL = max(params.ABI) - min(params.ILD);
                ABImaxR = max(params.ABI);
            otherwise 
                ABImaxL = max(params.ABI) - min(params.ILD)/2; 
                ABImaxR = max(params.ABI) + max(params.ILD)/2; 
        end 
end

% check if desired intensity is below the max achievable intensity 
switch upper(curve.side)
    case 'BOTH'
        if (ABImaxL>Lmax) || (ABImaxR>Rmax)
            warndlg(['Max intensities: Left = ', num2str(Lmax)...
                    ' dB, Right = ', num2str(Rmax) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end 
    case 'LEFT'
        if (ABImaxL>Lmax)
            warndlg(['Max intensity: Left = ', num2str(Lmax) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end 
    case 'RIGHT'
        if (ABImaxR>Rmax)
            warndlg(['Max intensity: Right = ', num2str(Rmax) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end 
end

% calculate min achievable intensity
Lmin = Lmax - MAXATTEN;
Rmin = Rmax - MAXATTEN;

% calculate min desired intensity
switch upper(curve.side)
    case { 'LEFT', 'RIGHT' } 
        ABIminR = min(params.ABI);
        ABIminL = min(params.ABI);
    case 'BOTH'
        switch upper(params.curvetype)
            case 'FILDL' 
                ABIminL = min(params.ABI);
                ABIminR = min(params.ABI) + min(params.ILD);
            case 'FILDR'
                ABIminL = min(params.ABI) - max(params.ILD);
                ABIminR = min(params.ABI);
            otherwise 
                ABIminL = min(params.ABI) - max(params.ILD)/2; 
                ABIminR = min(params.ABI) + min(params.ILD)/2; 
        end 
end

% check if desired intensity is above the min achievable intensity 
switch upper(handles.h2.curve.side)
    case 'BOTH'
        if (ABIminL<Lmin) || (ABIminR<Rmin)
            warndlg(['Min intensities: Left = ', num2str(Lmin)...
                    ' dB, Right = ', num2str(Rmin) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end    
    case 'LEFT'
        if (ABIminL<Lmin)
            warndlg(['Min intensity: Left = ', num2str(Lmin) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end    
    case 'RIGHT'
        if (ABIminR<Rmin)
            warndlg(['Min intensity: Right = ', num2str(Rmin) ' dB'], 'ABI error'); 
            CurveSuccessFlag = -2; % failed 
            return;
        end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check stimulus types (tone or noise) according to curve type
switch upper(params.curvetype)

    case { 'BF', 'CF', 'CD', 'BEAT' } % tone only with these curve types
        if strcmp(curve.stimtype, 'NOISE')
            warndlg(['Only TONE can be used with ' params.curvetype], 'stimulus type error');
            CurveSuccessFlag = -2; % failed
            return; 
        end
    
%    case { 'BC', 'SAMP', 'SAMF' } % noise only with these curve types
    case { 'BC' } % noise only with 'BC' (now SAM can be used with tone, Jan 2015)
        if strcmp(curve.stimtype, 'TONE')
            warndlg(['Only NOISE can be used with ' params.curvetype], 'stimulus type error');
            CurveSuccessFlag = -2; % failed
            return; 
        end
end

% check stimulus sides (B/L/R) according to curve type
switch upper(params.curvetype)

    case { 'ITD', 'ILD', 'BC', 'CD', 'FILDL', 'FILDR', 'BEAT' } % binaural only with these curve types
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
            warndlg('lower and upper frequencies are needed for NOISE', 'frequency error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'TONE'
        params.BC = 100;
%        params.sAMp = 0; (now SAM can be used with tone, Jan 2015)
%        params.sAMf = 0; (now SAM can be used with tone, Jan 2015)

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

    case { 'ILD', 'FILDL', 'FILDR' } % 'TONE' or 'NOISE'
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

    case 'SAMP' % 'NOISE' or 'TONE' (Jan 2015)
        loopvars{1} = 'SAMP'; 
        loopvars{2} = 'NONE'; 
        nloopvars = 1;
        if sum([ (nITD>1), (nILD>1), (nABI>1), (nsAMf>1)]) > 1
            warndlg('Only one parameter in addition to sAMp can be varied', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end

    case 'SAMF' % 'NOISE' or 'TONE' (Jan 2015)
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
        
    case 'BEAT' % 'TONE' only
        loopvars{1} = 'NONE'; 
        loopvars{2} = 'NONE';
        nloopvars = 0;
        if sum([ (nITD>1), (nILD>1), (nABI>1), (nBC>1), (nsAMp>1), (nsAMf>1)]) > 1
            warndlg('Only Freq can varied', 'parameter error');
            CurveSuccessFlag = -2; % failed
            return; 
        end
        
    otherwise 
        errordlg('error: unknown curve type');
        CurveSuccessFlag = -3; % failed: fatal error
        return; 
end

if (nFreq<1) || (nITD<1) || (nILD<1) || (nABI<1) || (nBC<1) || (nsAMp<1) || (nsAMf<1)
    warndlg('Empty parameters found. Stop...', 'parameter error');
    CurveSuccessFlag = -2; % failed
    return; 
end

% determine the second loop variable 
if (nFreq>1) && ~strcmp(loopvars{1},'FREQ') && ~strcmp(curve.stimtype, 'NOISE') && ~strcmpi( params.curvetype, 'BEAT' )
    loopvars{2} = 'FREQ'; 
    nloopvars = 2;
end
if (nITD>1) && ~strcmp(loopvars{1},'ITD')
    loopvars{2} = 'ITD'; 
    nloopvars = 2;
end
if (nILD>1) &&  ~strcmp(loopvars{1},'ILD') && ...
            ~strcmp(loopvars{1},'FILDL') && ~strcmp(loopvars{1},'FILDR')
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

% show loop variables
disp(['loop variables : ' loopvars{1} ' ' loopvars{2}]);
stimcache.loopvars = loopvars;
stimcache.nloopvars = nloopvars;

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
    [curvefile, curvepath] = TytoLogy2_buildFileName(animal, params.curvetype);
    % if curvefilename == 0, user selected 'cancel',  
    % so cancel the running of curve and return from function
	if curvefile == 0
        CurveSuccessFlag = -1; 
		return;
	end
end

% mat file to save curve results
[pathstr, filestr, extstr] = fileparts(curvefile);
curvesettingsfile = [pathstr filesep filestr '.mat'];
curvedat2file = [pathstr filesep filestr '.dat2'];

% display info
disp(['data saved to: ' pathstr filesep filestr '.mat(.dat2)' ]);

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
    if( ~strcmpi( params.curvetype, 'BEAT' )),
        ntrials = nFreq * nITD * nILD * nABI * nBC * nsAMp * nsAMf;
    else
        ntrials = 1;
    end
else % if 'NOISE'
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
if( ~strcmpi( params.curvetype, 'BEAT' ))
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
% if 'BEAT' is used, then Freq indicates left and right freqs
    sindex = sindex + 1;
    tempcache.Freq{sindex}  = [ params.Freq(1) params.Freq(2) ];
    tempcache.ITD(sindex) = params.ITD(iITD);
    tempcache.ILD(sindex) = params.ILD(iILD);
    tempcache.ABI(sindex) = params.ABI(iABI);
    tempcache.BC(sindex)  = params.BC(iBC);
    tempcache.sAMp(sindex)  = params.sAMp(isAMp);
    tempcache.sAMf(sindex)  = params.sAMf(isAMf);
end
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

% make random sequence
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

        % Note:: stimcache: randomized, tmpcache: sorted 
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

    case { 'SAMP', 'SAMF' } % for amplitude modulated sounds
        if( strcmpi( stimcache.stimtype, 'TONE' )),
            % get Smag and Sphase, using ITD=0, sAMp=50, sAMf=10, AMphi=0, rad_vary=0 (dummy data)
            [ S0, Scale0, ModPhi0, Smag0, Sphase0 ] = ...
                syn_headphone_amtone( stimulus.Duration, outFs, tempcache.Freq{1}, ...
                0, 50, 10, 0, 0, caldata );
        else
            % get Smag and Sphase, using ITD=0, sAMp=50, sAMf=10, AMphi=0  (dummy data)
            [S0, Scale0, ScaleMod0, ModPhi0, Smag0, Sphase0] = ...
                syn_headphone_amnoise(stimulus.Duration, outFs, ...
                tempcache.Freq{1}, 0, tempcache.BC(1), 50, 10, 0, caldata);
        end
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
                case { 'SAMP', 'SAMF' } % for amplitude modulated sounds
                    if( strcmpi( stimcache.stimtype, 'TONE' )),
                        [ Sn, rms_mod, modPhi, Smag0, Sphase0 ] = ...
                            syn_headphone_amtone( stimulus.Duration, outFs, tmpfreq, ...
                            tmpITD, tmpsAMp, tmpsAMf, 0, 0, caldata );
                    else
                        [ Sn, rmsval, rms_mod, modPhi ] = ...
                            syn_headphone_amnoise(stimulus.Duration, outFs, ...
                            tmpfreq, tmpITD, tmpBC, tmpsAMp, tmpsAMf, 0, ...
                            caldata, Smag0, Sphase0);
                    end
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
            case { 'SAMP', 'SAMF' } % for amplitude modulated sound
                if( strcmpi( stimcache.stimtype, 'TONE' )),
                    [ Sn, rms_mod, modPhi, Smag0, Sphase0 ] = ...
                        syn_headphone_amtone( stimulus.Duration, outFs, tmpfreq, ...
                        tmpITD, tmpsAMp, tmpsAMf, 0, 0, caldata );
                else
                    [Sn, rmsval, rms_mod, modPhi] = ...
                        syn_headphone_amnoise(stimulus.Duration, outFs, ...
                        tmpfreq, tmpITD, tmpBC, tmpsAMp, tmpsAMf, [], caldata);
                end
            case 'BEAT'
                if( length( tmpfreq ) > 1 )
                    [SLn, rmsvalL] = syn_headphone_tone(stimulus.Duration, outFs,...
                        tmpfreq( 1 ), 0, 0, caldata);
                    [SRn, rmsvalR] = syn_headphone_tone(stimulus.Duration, outFs,...
                        tmpfreq( 2 ), 0, 0, caldata);
                    Sn = [ SLn( 1, : ); SRn( 2, : )];
                    rmsval = [ rmsvalL( 1 ); rmsvalR( 2 )];
                else
                    [Sn, rmsval] = syn_headphone_tone(stimulus.Duration, outFs,...
                         tmpfreq, 0, 0, caldata);
                end
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
        switch upper(params.curvetype)
            case 'FILDL'
                spl_val(L) = tmpABI; 
                spl_val(R) = tmpABI + tmpILD; 
            case 'FILDR'
                spl_val(L) = tmpABI - tmpILD; 
                spl_val(R) = tmpABI; 
            otherwise
                spl_val = computeLRspl(tmpILD, tmpABI);
        end

        % get the attenuator settings for the desired SPL
        switch upper(params.curvetype)
        case { 'SAMP', 'SAMF' } % for amplitude modulated sound
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
        case { 'SAMP', 'SAMF' } % for amplitude modulated sound
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

% make cells to store data
resp = cell(ntrials, nreps); % sorted raw data traces
spike_times = cell(ntrials, nreps); 
spike_counts = zeros(ntrials, nreps);
isspont = zeros(ntrials, nreps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup for Curve plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = (stimcache.isspont(:,1)==0); 
x1 = stimcache.loopvar(:,1);
x2 = stimcache.loopvar(:,2);
curveX = sort(unique(x1(j))); % depvar1 of non-spont trials
curveY = sort(unique(x2(j))); % depvar2 of non-spont trials
curveN = zeros(length(curveX), length(curveY));
curveM = zeros(length(curveX), length(curveY));
curveV = zeros(length(curveX), length(curveY));
curveC = {'kx-', 'bx-', 'gx-', 'rx-', 'cx-', 'yx-'};
spontX = [ min(curveX) max(curveX) ];
spontN = 0;
spontM = 0;
spontV = 0;
spontC = 'mo-';
if sum(~isnan(curveX))==0
    curveX = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write data file header - this will create a binary data file
% Adopted from writeDataFileHeader with modification (Aug 2012, GA)
% writeDataFileHeader2(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the date and time
time_start = now;

% create binary file 
fp = fopen(curvedat2file, 'w');

% if something is wrong with file opening, then abort
if fp==-1
    warndlg('Curve module -- Cannot create a binary file');
    CurveSuccessFlag = -1; 
    return; 
end

%-------------------------
% write the header info
%-------------------------
% write the filename 
TytoLogy2_writebinary(fp, 'string', curvedat2file, 'datafile');
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
% write the curve structure
TytoLogy2_writebinary(fp, 'struct', curve, 'click');
% write the caldata structure
TytoLogy2_writebinary(fp, 'struct', caldata, 'caldata');
% write the stimcache structure 
if curve.SaveStim
    TytoLogy2_writebinary(fp, 'struct', stimcache, 'stimcache');
else
    TytoLogy2_writebinary(fp, 'struct', rmfield(stimcache, 'Sn'), 'stimcache');
end
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
atten = [MAXATTEN MAXATTEN]; % max attenuation
handles.h2.config.setattenFunc(handles.PA5L, atten(L));
handles.h2.config.setattenFunc(handles.PA5R, atten(R));
Sn = zeros(2,ms2bin(stimulus.Duration, outFs));
[sponttrace, spontnpts, sponttraceu, spontnptsu] = ...
    handles.h2.config.ioFunc(Sn, acqpts, indev, outdev, zBUS);
% if no input, then make a dummy trace 
if std(sponttrace) == 0
    sponttrace = 0.1*randn(size(sponttrace));
end
% calculate SD of the spont trace as threshold reference
refSD = std(sponttrace);

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
    str0 = sprintf('rep = %d/%d  (%d/%d) : ', rep, nreps, sindex, nstims);
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
            str2 = sprintf('\n');
        else
            str2 = sprintf(',  %s = %.0f\n', lower(loopvars{2}), stimcache.loopvar(sindex,2));
        end
    end

    update_ui_str(handles.textMessage, [ isistr str0 str1 str2 'Output: ', curvefile ]);

    %-------------------------------------
    % set the attenuators
    %-------------------------------------
    % get the attenuator values
    atten = stimcache.atten{sindex};

    % Note: the function handle 'handles.h2.config.setattenFunc' is 
    %       defined in HPSearch2c_config()
    handles.h2.config.setattenFunc(handles.PA5L, atten(L));
    handles.h2.config.setattenFunc(handles.PA5R, atten(R));

    %-------------------------------------
    % now play the sound and return the response
    % Note: the function handle 'handles.h2.config.ioFunc' is 
    %       defined in HPSearch2c_config()
    %-------------------------------------
    % get the stimulus waveform 
    Sn = stimcache.Sn{sindex};

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
    fp = fopen(curvedat2file, 'a');

    % if something is wrong with file opening, then give a warning
    if fp==-1
        warndlg('Curve module -- Cannot open a binary file');
    else
        % write the dataID
        TytoLogy2_writebinary(fp, 'vector', stimcache.loopvar(sindex,:), 'loopvar', 'double');
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
    % Note: by indexing the response using row values from the stimseq array, 
    %       the resp{} data will be in SORTED form! (SJS)
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

    % calculating spike rate within the analysis window
    a_start = ms2samples(analysis.StartTime, inFs);  
    a_end   = ms2samples(analysis.EndTime, inFs); 
    a_idx = [ zeros(1,a_start) ones(1,a_end-a_start), zeros(1,length(spidx)-a_end) ]; 
    a_spidx = spidx & a_idx(1:length(spidx)); 
    a_nspike = sum(a_spidx);  % number of spikes within the analysis window
    a_rate = 1000 * a_nspike / (analysis.EndTime-analysis.StartTime);
    % show spike rate
    update_ui_str(handles.editRate, a_rate);

    % store data 
    spike_times{stimseq(rep, trial), rep} = tvec(spidx);
    spike_counts(stimseq(rep, trial), rep) = a_nspike;
    isspont(stimseq(rep, trial), rep) = stimcache.isspont(sindex);

    %-------------------------------------
    % plotting data
    %-------------------------------------
    % dummy frequency info used for plots
    plotparams.minfreq = min(params.Freq); 
    plotparams.maxfreq = max(params.Freq);
    
    % call plotting script
    HPSearch2c_plotResponse;

    % call curve plotting script
    HPSearch2c_plotCurve;

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
fp = fopen(curvedat2file, 'a');

% if something is wrong with file opening, then do nothing
if fp==-1
    warndlg('Curve module -- Cannot open a binary file');
else
    % write a string that says 'DATA_END'
    TytoLogy2_writebinary(fp, 'string', 'DATA_END', '???')
    % write the end time 
    TytoLogy2_writebinary(fp, 'vector', time_end, 'time_end', 'double');
    % close the file
    fclose(fp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gather collected data into curvedata structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curvedata = [];
if ~cancelFlag
    curvedata.depvars = stimcache.depvars; % unsorted
    curvedata.depvars_sort = stimcache.depvars_sort; % sorted
    curvedata.spike_times = spike_times; % sorted
    curvedata.spike_counts = spike_counts; % sorted
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
    curvesettings.dataversion = HPSearch2c_init('DATAVERSION');
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

    %-------------------------------------
    % save the curvesettings struct (has curve information) and 
    % the curvedata struct (has curve data spike counts but NO RAW DATA!).  
    % IMPORTANT: remember that the data in curve data are already sorted 
    %            into a [# of test values X # of reps] array (SJS)
    %-------------------------------------
    curveresp = resp;
    save(curvesettingsfile, '-MAT', 'curvesettings', 'curvedata', 'curveresp');

    % if succeeded then flag=1
    CurveSuccessFlag = 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot curve data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(curvedata) && ~cancelFlag

    TytoView_simpleplot(curvedata, curvesettings);

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
