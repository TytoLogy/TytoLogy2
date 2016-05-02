function varargout = TytoSpanGUI(varargin)
% TYTOSPANGUI M-file for TytoSpanGUI.fig
%   TYTOSPANGUI, by itself, creates a new TYTOSPANGUI or raises the existing singleton*.
%
%   H = TYTOSPANGUI returns the handle to a new TYTOSPANGUI or the handle to
%      the existing singleton*.

% Last Modified by GUIDE v2.5 06-Nov-2013 20:06:32

%------------------------------------------------------------------------
%  TytoSpanGUI -- GUI based TytoLogy SPike ANalysis tool 
%------------------------------------------------------------------------
%  Go Ashida 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Versions 
%  Oct 2013 -- origical version created by GA 
%  Jul 2015 -- added code for noise stim by GA
%------------------------------------------------------------------------
% ** Important Notes ** 
%  (Oct 2013, GA)
%   This file is for analyzing HPSearch2a/b/c data 
%--------------------------------------------------------------------------
% [ Major Subroutines ] 
% 
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Initialization code automatically created by Matlab GUIDE ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Begin initialization code - DO NOT EDIT 
%--------------------------------------------------------------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TytoSpanGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TytoSpanGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%--------------------------------------------------------------------------
% End initialization code - DO NOT EDIT
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before TytoSpanGUI is made visible.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function TytoSpanGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % choose default command line output for TytoSpanGUI
    handles.output = hObject;
    % create f structure under handles (to store flags)
    handles.f = struct();
    handles.f.loaded = 0;
    handles.f.completed = 0;
    handles.f.filtered = 0;
    handles.f.threshold =0;
    % create d structure under handles (to store loaded data)
    handles.d = struct();
    % create a structure under handles (to store analysis results)
    handles.a = struct();
    % create v structure under handles (to store variables)
    handles.v = struct();
    % set default values
    handles.v.TrFiltered = 1;
    handles.v.TrN = [1 2 3 4 5];
    handles.v.F1 = 100;
    handles.v.F2 = 10000;
    handles.v.Dim = 6;
    handles.v.DB = 20;
    handles.v.Mean = 1;
    handles.v.Filt = 'NO'; 
    handles.v.ThAuto = 1; 
    handles.v.Peak = 0; 
    handles.v.ThresSD = 4.0;
    handles.v.Threshold = 2.0;
    handles.v.Scale = 1.0e-2; 
    handles.v.Sign = 1.0; 
    handles.v.Window = 1.0; 
    handles.v.Start = 10.0; 
    handles.v.End = 60.0; 
    % set plot handles
    handles.ploth = zeros(3,5);
    handles.ploth(1,1) = handles.plotA1; 
    handles.ploth(1,2) = handles.plotA2; 
    handles.ploth(1,3) = handles.plotA3; 
    handles.ploth(1,4) = handles.plotA4; 
    handles.ploth(1,5) = handles.plotA5; 
    handles.ploth(2,1) = handles.plotB1; 
    handles.ploth(2,2) = handles.plotB2; 
    handles.ploth(2,3) = handles.plotB3; 
    handles.ploth(2,4) = handles.plotB4; 
    handles.ploth(2,5) = handles.plotB5; 
    handles.ploth(3,1) = handles.plotC1; 
    handles.ploth(3,2) = handles.plotC2; 
    handles.ploth(3,3) = handles.plotC3; 
    handles.ploth(3,4) = handles.plotC4; 
    handles.ploth(3,5) = handles.plotC5; 
    enable_ui(handles.radioThPlus);
    enable_ui(handles.radioThMinus);
    % update handles structure
    guidata(hObject, handles);
    % show message
    str = '** TytoSpanGUI: opening function called';
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function varargout = TytoSpanGUI_OutputFcn(hObject, eventdata, handles) 
    % show message
    str = '** TytoSpanGUI: output function called';
    set(handles.textMessage, 'String', str);
    % set output
    varargout{1} = handles.output;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Cleaning up before closing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function TytoSpanGUI_CloseRequestFcn(hObject, eventdata, handles)
    % show message 
    str = '** TytoSpanGUI: closing function called';
    set(handles.textMessage, 'String', str);
    disp(str); % also show message to the command window
    % delete GUI
    delete(hObject);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Load File button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonLoadMat_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TytoSpanGUI: Load Mat File button pressed';
    set(handles.textMessage, 'String', str);
    % ask user for a file name 
	[fname, fpath] = ...
        uigetfile('*.mat', 'Load HPSearch2 data ...');
	if fname == 0 % return if user hits CANCEL button 
        str = 'Data Loading Cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % try to load HPSearch2 data file
    try 
		tmpdata = load(fullfile(fpath, fname)); 
    catch % on error, tmpdata is empty
		tmpdata = [];
        str = 'Loading error. Invalid data file?';
        set(handles.textMessage, 'String', str);
        return;
    end
    % check if the loaded file containes required structures
    if isfield(tmpdata,'curvesettings') && isfield(tmpdata,'curvedata')
        handles.d.filename = fullfile(fpath, fname);
        handles.d.curvesettings = tmpdata.curvesettings;
        handles.d.curvedata = tmpdata.curvedata;
        handles.d.curveresp = tmpdata.curveresp;
        handles.d.filteresp = cell(size(tmpdata.curveresp));
        % show message and file name
        str = 'Data File Loaded';
        set(handles.textMessage, 'String', str);
        update_ui_str(handles.textFileName, fullfile(fpath, fname));
    else 
        str = sprintf('Invalid HPSearch2 data file: \n%s', fname);
        errordlg(str,'Loading Error');
        return;
    end

    % get freq info (updated Jul 2015 by GA)
%    f = unique(cell2mat(tmpdata.curvesettings.stimcache.Freq)); % for only tone
%    f = f(f>=0); % remove spont (freq=-99999)
    fmin = unique(cell2mat(cellfun(@(x){min(x)}, tmpdata.curvesettings.stimcache.Freq))); % for tone and noise 
    fmin = min( fmin(fmin>=0) ); % remove spont (freq=-99999) and get min 
    fmax = unique(cell2mat(cellfun(@(x){max(x)}, tmpdata.curvesettings.stimcache.Freq))); % for tone and noise 
    fmax = max( fmax(fmax>=0) ); % remove spont (freq=-99999) and get max

    % show data info 
    str = '';
    str = sprintf('%sinFs : %.1f [Hz]\n', str, tmpdata.curvesettings.Fs(1)); 
    str = sprintf('%soutFs: %.1f [Hz]\n', str, tmpdata.curvesettings.Fs(2)); 
    str = sprintf('%sNreps  : %d\n', str, tmpdata.curvesettings.stimcache.nreps); 
    str = sprintf('%sNtrials: %d\n', str, tmpdata.curvesettings.stimcache.ntrials); 
    str = sprintf('%sNstims : %d\n', str, tmpdata.curvesettings.stimcache.nstims); 
    str = sprintf('%sLeftON : %d\n', str, tmpdata.curvesettings.stimcache.LeftON); 
    str = sprintf('%sRightON: %d\n', str, tmpdata.curvesettings.stimcache.RightON); 
    str = sprintf('%sCancelFlag: %d\n', str, tmpdata.curvedata.cancelFlag); 
    str = sprintf('%sLoopVar1: %s\n', str, tmpdata.curvesettings.stimcache.loopvars{1}); 
    str = sprintf('%sLoopVar2: %s\n', str, tmpdata.curvesettings.stimcache.loopvars{2}); 
 %   str = sprintf('%sMin Freq: %.1f\n', str, min(f)); % old 2013
 %   str = sprintf('%sMax Freq: %.1f\n', str, max(f)); % old 2013
    str = sprintf('%sMin Freq: %.1f\n', str, fmin); % new Jul 2015
    str = sprintf('%sMax Freq: %.1f\n', str, fmax); % new Jul 2015
    set(handles.textStat2, 'String', str);
    str = '';
    str = sprintf('%sISI     : %.1f [ms]\n', str, tmpdata.curvesettings.stim.ISI); 
    str = sprintf('%sAcqDur  : %.1f [ms]\n', str, tmpdata.curvesettings.tdt.AcqDuration); 
    str = sprintf('%sDuration: %.1f [ms]\n', str, tmpdata.curvesettings.stim.Duration); 
    str = sprintf('%sDelay   : %.1f [ms]\n', str, tmpdata.curvesettings.stim.Delay); 
    str = sprintf('%sRamp    : %.1f [ms]\n', str, tmpdata.curvesettings.stim.Ramp); 
    str = sprintf('%sRadVary: %d\n', str, tmpdata.curvesettings.stim.RadVary); 
    str = sprintf('%sFrozen : %d\n', str, tmpdata.curvesettings.stim.Frozen); 
    str = sprintf('%sSpont  : %d\n', str, tmpdata.curvesettings.curve.Spont); 
    str = sprintf('%sStim   : %s\n', str, tmpdata.curvesettings.curve.stimtype); 
    str = sprintf('%sSide   : %s\n', str, tmpdata.curvesettings.curve.side); 
    str = sprintf('%sHPFreq : %.1f [Hz]\n', str, tmpdata.curvesettings.tdt.HPFreq); 
    str = sprintf('%sLPFreq : %.1f [Hz]\n', str, tmpdata.curvesettings.tdt.LPFreq); 
    set(handles.textStat1, 'String', str);
    % copy useful parameters
    handles.v.inFs = handles.d.curvesettings.Fs(1);
    handles.v.nreps  = handles.d.curvesettings.stimcache.nreps;
    handles.v.ntrials= handles.d.curvesettings.stimcache.ntrials;
    handles.v.nstims = handles.d.curvesettings.stimcache.nstims;
    handles.v.loopvars= handles.d.curvesettings.stimcache.loopvars;
    handles.v.depvar1 = handles.d.curvedata.depvars_sort(:,:,1);
    handles.v.depvar2 = handles.d.curvedata.depvars_sort(:,:,2);
    % reset flags
    handles.f.loaded = 1;
    handles.f.filtered = 0;
    handles.f.threshold = 0;
    % enable/disable controls
    enable_ui(handles.buttonApplyFilt);
    disable_ui(handles.buttonApplyTh);
    enable_ui(handles.buttonSave);
    disable_ui(handles.radioTrFilt);
    disable_ui(handles.radioTrUnfilt);
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function buttonLoadDat_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TytoSpanGUI: Load Dat File button pressed';
    set(handles.textMessage, 'String', str);
    % ask user for a file name 
	[fname, fpath] = ...
        uigetfile('*.dat2', 'Load HPSearch2 binary data ...');
	if fname == 0 % return if user hits CANCEL button 
        str = 'Data Loading Cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % load HPSearch2 data file
    [ tmpdata, tmpinfo ] = TytoSpan_readdat2(fullfile(fpath, fname)); 
    % check validity
    if isempty(tmpdata)
        str = 'Loading error. Invalid data file?';
        set(handles.textMessage, 'String', str);
        return;
    end
    % copy and align important data
    nread   = tmpinfo.nread; % number of traces actually recorded 
    ntrials = tmpinfo.stimcache.ntrials; 
    nreps_orig = tmpinfo.stimcache.nreps; % number of original reps
    nreps  = ceil(nread/ntrials); % number of actual reps
    nstims = ntrials * nreps; 
    depvars = zeros(ntrials,nreps,2); 
    depvars_sort = zeros(ntrials,nreps,2); 
    depvars(:,:,1) = tmpinfo.stimcache.depvars(:,1:nreps);
    depvars(:,:,2) = tmpinfo.stimcache.depvars(:,(nreps_orig+1):(nreps_orig+nreps));
    depvars_sort(:,:,1) = tmpinfo.stimcache.depvars_sort(:,1:nreps);
    depvars_sort(:,:,2) = tmpinfo.stimcache.depvars_sort(:,(nreps_orig+1):(nreps_orig+nreps));
    % copy curvesettings data
    curvesettings = struct();
    curvesettings.time_start = datestr(tmpinfo.time_start);
    curvesettings.time_stop = datestr(tmpinfo.time_end);
    curvesettings.dataversion = tmpinfo.dataversion;
    curvesettings.curvesettingsfile = tmpinfo.datafile;
    curvesettings.Fs = tmpinfo.Fs';
    curvesettings.stim = tmpinfo.stim;
    curvesettings.tdt = tmpinfo.tdt;
    curvesettings.channels = tmpinfo.channels;
    curvesettings.analysis_orig = tmpinfo.analysis;
    curvesettings.animal = ...
        structfun(@(x) char(x), tmpinfo.animal, 'UniformOutput', false);
    curvesettings.caldata = tmpinfo.caldata;
    if isfield(tmpinfo,'click')
        curvesettings.curve = tmpinfo.click; 
    else
        curvesettings.curve = tmpinfo.curve; 
    end
    curvesettings.curve.stimtype = char(curvesettings.curve.stimtype);
    curvesettings.curve.side = char(curvesettings.curve.side);
    curvesettings.stimcache = tmpinfo.stimcache; 
    curvesettings.stimcache.loopvars{1} = char(curvesettings.stimcache.loopvars{1});
    curvesettings.stimcache.loopvars{2} = char(curvesettings.stimcache.loopvars{2});
    curvesettings.stimcache.curvetype = char(curvesettings.stimcache.curvetype);
    curvesettings.stimcache.stimtype = char(curvesettings.stimcache.stimtype);
    curvesettings.stimcache.side = char(curvesettings.stimcache.side);
    curvesettings.stimcache.nread = nread;
    curvesettings.stimcache.nreps = nreps;
    curvesettings.stimcache.nreps_orig = nreps_orig;
    curvesettings.stimcache.nstims = nstims;
    curvesettings.stimcache.depvars = depvars;
    curvesettings.stimcache.depvars_sort = depvars_sort;
    % make curvedata structure 
    curvedata = struct();
    curvedata.depvars = depvars;
    curvedata.depvars_sort = depvars_sort; 
    curvedata.spike_times = cell(ntrials,nreps); 
    curvedata.spike_counts = zeros(ntrials,nreps); 
    curvedata.isspont = zeros(ntrials,nreps);
    if tmpinfo.complete
        curvedata.cancelFlag = 0;
    else
        curvedata.cancelFlag = 1; 
    end
    % copy curvesetting, curvedata and other info under handles.d
    handles.d.filename = fullfile(fpath, fname);
    handles.d.curvesettings = curvesettings; 
    handles.d.curvedata = curvedata;
    handles.d.resp = cell(ntrials,nreps);
    handles.d.respu = cell(ntrials,nreps);
    handles.d.curveresp = cell(ntrials,nreps);
    handles.d.filteresp = cell(ntrials,nreps);
    handles.d.curvedata.isactual = zeros(ntrials,nreps); % flag for 'real' data
    % copy useful parameters
    handles.v.inFs = tmpinfo.Fs(1);
    handles.v.nreps  = nreps;
    handles.v.ntrials= ntrials;
    handles.v.nstims = nstims;
    handles.v.loopvars= curvesettings.stimcache.loopvars;
    handles.v.depvar1 = depvars_sort(:,:,1);
    handles.v.depvar2 = depvars_sort(:,:,2);
    % show message and file name
    str = 'Data File Loaded';
    set(handles.textMessage, 'String', str);
    update_ui_str(handles.textFileName, fullfile(fpath, fname));

    % get freq info (updated Jul 2015 by GA)
%    f = unique(cell2mat(curvesettings.stimcache.Freq)); % for only tone
%    f = f(f>=0); % remove spont (freq=-99999)
    fmin = unique(cell2mat(cellfun(@(x){min(x)}, curvesettings.stimcache.Freq))); % for tone and noise 
    fmin = min( fmin(fmin>=0) ); % remove spont (freq=-99999) and get min 
    fmax = unique(cell2mat(cellfun(@(x){max(x)}, curvesettings.stimcache.Freq))); % for tone and noise 
    fmax = max( fmax(fmax>=0) ); % remove spont (freq=-99999) and get max

    % show data info 
    str = '';
    str = sprintf('%sinFs : %.1f [Hz]\n', str, curvesettings.Fs(1)); 
    str = sprintf('%soutFs: %.1f [Hz]\n', str, curvesettings.Fs(2)); 
    str = sprintf('%sNreps  : %d\n', str, curvesettings.stimcache.nreps); 
    str = sprintf('%sNtrials: %d\n', str, curvesettings.stimcache.ntrials); 
    str = sprintf('%sNstims : %d\n', str, curvesettings.stimcache.nstims); 
    str = sprintf('%sLeftON : %d\n', str, curvesettings.stimcache.LeftON); 
    str = sprintf('%sRightON: %d\n', str, curvesettings.stimcache.RightON); 
    str = sprintf('%sCancelFlag: %d\n', str, curvedata.cancelFlag); 
    str = sprintf('%sLoopVar1: %s\n', str, curvesettings.stimcache.loopvars{1}); 
    str = sprintf('%sLoopVar2: %s\n', str, curvesettings.stimcache.loopvars{2}); 
%    str = sprintf('%sMin Freq: %.1f\n', str, min(f)); % old 2013
%    str = sprintf('%sMax Freq: %.1f\n', str, max(f)); % old 2013
    str = sprintf('%sMin Freq: %.1f\n', str, fmin); % new Jul 2015
    str = sprintf('%sMax Freq: %.1f\n', str, fmax); % new Jul 2015
    set(handles.textStat2, 'String', str);
    str = '';
    str = sprintf('%sISI     : %.1f [ms]\n', str, curvesettings.stim.ISI); 
    str = sprintf('%sAcqDur  : %.1f [ms]\n', str, curvesettings.tdt.AcqDuration); 
    str = sprintf('%sDuration: %.1f [ms]\n', str, curvesettings.stim.Duration); 
    str = sprintf('%sDelay   : %.1f [ms]\n', str, curvesettings.stim.Delay); 
    str = sprintf('%sRamp    : %.1f [ms]\n', str, curvesettings.stim.Ramp); 
    str = sprintf('%sRadVary: %d\n', str, curvesettings.stim.RadVary); 
    str = sprintf('%sFrozen : %d\n', str, curvesettings.stim.Frozen); 
    str = sprintf('%sSpont  : %d\n', str, curvesettings.curve.Spont); 
    str = sprintf('%sStim   : %s\n', str, curvesettings.curve.stimtype); 
    str = sprintf('%sSide   : %s\n', str, curvesettings.curve.side); 
    str = sprintf('%sHPFreq : %.1f [Hz]\n', str, curvesettings.tdt.HPFreq); 
    str = sprintf('%sLPFreq : %.1f [Hz]\n', str, curvesettings.tdt.LPFreq); 
    set(handles.textStat1, 'String', str);
    % make dummy trace (for non-existing traces)
    acqd = handles.d.curvesettings.tdt.AcqDuration;
    inFs = handles.d.curvesettings.Fs(1);
    acqp = ms2samples(acqd, inFs);
    dummytrace = zeros(acqp,1);
    % rep and trial numbers 
    repnum = zeros(nstims,1);
    trialnum = zeros(nstims,1);
    sindex = 0;
    for ireps = 1:nreps
        for itrials = 1:ntrials
            sindex = sindex + 1;
            repnum(sindex) = ireps;
            trialnum(sindex) = itrials;
        end
    end
    % assign sorted traces to cell array
    stimseq = curvesettings.stimcache.trialRandomSequence; 
    for sindex = 1:nstims
        rep   = repnum(sindex);
        trial = trialnum(sindex);
        handles.d.curvedata.isspont(stimseq(rep,trial),rep) = tmpinfo.stimcache.isspont(sindex);
        if sindex > nread % for non-existing data
            handles.d.resp{stimseq(rep,trial),rep} = dummytrace;
            handles.d.respu{stimseq(rep,trial),rep} = dummytrace;
            handles.d.curvedata.isactual(stimseq(rep,trial),rep) = 0;
        else 
            handles.d.resp{stimseq(rep,trial),rep} = tmpdata{sindex}.datatrace;
            handles.d.respu{stimseq(rep,trial),rep} = tmpdata{sindex}.datatraceu;
            handles.d.curvedata.isactual(stimseq(rep,trial),rep) = 1;
        end
    end    
    % copy data to curveresp according to the flag
    if handles.v.TrFiltered
        handles.d.curveresp = handles.d.resp;
    else
        handles.d.curveresp = handles.d.respu;
    end
    % set flags
    handles.f.loaded = 1; 
    handles.f.filtered = 0;
    handles.f.threshold = 0;
    % enable/disable controls
    enable_ui(handles.buttonApplyFilt);
    disable_ui(handles.buttonApplyTh);
    enable_ui(handles.buttonSave);
    enable_ui(handles.radioTrFilt);
    enable_ui(handles.radioTrUnfilt);
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function buttonSave_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TytoSpanGUI: Save Data button pressed';
    set(handles.textMessage, 'String', str);
    % make default file name
    [pathstr, filestr, extstr] = fileparts(handles.d.filename);
    defaultstr = [ filestr '_tytospan.mat' ];
    % ask user for a file name 
	[fname, fpath] = ...
        uiputfile('*.mat', 'Save HPSearch2 data ...', defaultstr);
	if fname == 0 % return if user hits CANCEL button 
        str = 'Data Saving Cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % copy data to the curve* structures
    curvesettings = handles.d.curvesettings; 
    curvedata = handles.d.curvedata; 
    curveresp = handles.d.curveresp;
    % check if spike detection has been done
    if handles.f.threshold
        curvedata.spike_times = handles.a.spike_times;
        curvedata.spike_counts = handles.a.spike_counts;
        curvesettings.analysis = handles.a.analysis;
    else
        nreps = curvesettings.stimcache.nreps;
        ntrials = curvesettings.stimcache.ntrials;
        curvedata.spike_times = cell(ntrials,nreps); 
        curvedata.spike_counts = zeros(ntrials,nreps); 
        curvesettings.analysis = struct();
    end
    % save data to the specified file 
    save(fullfile(fpath, fname), '-MAT', ...
        'curvesettings', 'curvedata', 'curveresp');
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Traces panel callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editP1_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Trace #1 changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    update_ui_str(hObject, tmp); %% update edit box 
    handles.v.TrN(1) = tmp;
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
function editP2_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Trace #2 changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    update_ui_str(hObject, tmp); %% update edit box 
    handles.v.TrN(2) = tmp;
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
function editP3_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Trace #3 changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    update_ui_str(hObject, tmp); %% update edit box 
    handles.v.TrN(3) = tmp;
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
function editP4_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Trace #4 changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    update_ui_str(hObject, tmp); %% update edit box 
    handles.v.TrN(4) = tmp;
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
function editP5_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Trace #5 changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    update_ui_str(hObject, tmp); %% update edit box 
    handles.v.TrN(5) = tmp;
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function buttonNext5_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Next5 button pressed';
    set(handles.textMessage, 'String', str);
    % update corresponding variables (limits are not checked)
    handles.v.TrN = handles.v.TrN + 5;
    update_ui_str(handles.editP1, handles.v.TrN(1)); 
    update_ui_str(handles.editP2, handles.v.TrN(2));  
    update_ui_str(handles.editP3, handles.v.TrN(3));  
    update_ui_str(handles.editP4, handles.v.TrN(4));  
    update_ui_str(handles.editP5, handles.v.TrN(5));  
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function buttonPrev5_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Prev5 button pressed';
    set(handles.textMessage, 'String', str);
    % update corresponding variables (limits are not checked)
    handles.v.TrN = handles.v.TrN - 5;
    update_ui_str(handles.editP1, handles.v.TrN(1)); 
    update_ui_str(handles.editP2, handles.v.TrN(2));  
    update_ui_str(handles.editP3, handles.v.TrN(3));  
    update_ui_str(handles.editP4, handles.v.TrN(4));  
    update_ui_str(handles.editP5, handles.v.TrN(5));  
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function radioFiltered_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '* Filtered? button pressed';
    set(handles.textMessage, 'String', str);
    % get selected value 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioTrFilt'
            % show message 
            str = 'Filtered Traces selected';
            set(handles.textMessage, 'String', str);
            % set the flag
            handles.v.TrFiltered = 1;
            % assign filtered response to curveresp structure
            handles.d.curveresp = handles.d.resp; 
        case 'radioTrUnfilt'
            % show message 
            str = 'Unfiltered Traces selected';
            set(handles.textMessage, 'String', str);
            % reset the flag
            handles.v.TrFiltered = 0;
            % assign unfiltered response to curveresp structure
            handles.d.curveresp = handles.d.respu; 
    end
    % reset flags
    handles.f.filtered = 0;
    handles.f.threshold = 0;
    % enable/disable controls
    enable_ui(handles.buttonApplyFilt);
    disable_ui(handles.buttonApplyTh);
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Filter panel callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonApplyFilt_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Apply Filter button pressed';
    set(handles.textMessage, 'String', str);
    % extract required info 
    nyq = handles.v.inFs/2; 
    ff1 = handles.v.F1;
    ff2 = handles.v.F2;
    fdm = handles.v.Dim; 
    fdb = handles.v.DB;
    % make a filter according to selected filter type 
    switch handles.v.Filt
        case 'LP' % low pass
            [b,a] = cheby2(fdm,fdb,ff2/nyq,'low');
        case 'HP' % high pass
            [b,a] = cheby2(fdm,fdb,ff1/nyq,'high'); 
        case 'BP' % band pass
            [b,a] = cheby2(fdm,fdb,[ff1/nyq,ff2/nyq]); 
        case 'BS' % band stop
            [b,a] = cheby2(fdm,fdb,[ff1/nyq,ff2/nyq],'stop');
    end
    % calculate means 
    nmax = handles.v.nstims;
    wmean = zeros(1,nmax);
    for i=1:nmax
        wmean(i) = mean(handles.d.curveresp{i}); 
    end
    % apply filter
    switch handles.v.Filt
        case 'NO' 
            for i=1:nmax
                str = sprintf('Applying dummy filter: %d/%d',i,nmax);
                set(handles.textMessage, 'String', str);
                handles.d.filteresp{i} = handles.d.curveresp{i};
            end
        otherwise
            for i=1:nmax
                str = sprintf('Applying %s filter: %d/%d',...
                                handles.v.Filt,i,nmax);
                set(handles.textMessage, 'String', str);
                handles.d.filteresp{i} = filtfilt(b,a,handles.d.curveresp{i}); 
            end
    end
    % Resume Mean value
    % Note: Mean becomes zero if high-pass or band-pass filter is used
    if handles.v.Mean
        switch handles.v.Filt
            case {'HP', 'BP'}
                for i=1:nmax
                    handles.d.filteresp{i} = handles.d.filteresp{i}+wmean(i);
                end
        end
    end
    % set the flag
    handles.f.filtered = 1;
    handles.f.threshold = 0;
    % enable Apply Threshold button
    enable_ui(handles.buttonApplyTh);
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function editF1_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Filter Min Freq changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checklim(tmp, [1 handles.v.F2-1]) % check limits
        update_ui_str(hObject, tmp); %% update edit box 
        handles.v.F1 = tmp;
        % update handles structure
        guidata(hObject, handles);
    else
        update_ui_str(hObject, handles.v.F1);
    end
function editF2_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Filter Max Freq changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checklim(tmp, [handles.v.F1+1 100000]) % check limits
        update_ui_str(hObject, tmp); %% update edit box 
        handles.v.F2 = tmp;
        % update handles structure
        guidata(hObject, handles);
    else
        update_ui_str(hObject, handles.v.F2);
    end
%--------------------------------------------------------------------------
function editFdim_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Filter Dimension changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checklim(tmp, [1 100]) % check limits
        update_ui_str(hObject, tmp); %% update edit box 
        handles.v.Dim = tmp;
        % update handles structure
        guidata(hObject, handles);
    else
        update_ui_str(hObject, handles.v.Dim);
    end
function editDB_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Filter dB changed';
    set(handles.textMessage, 'String', str);
    % update corresponding variable  
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checklim(tmp, [1 100]) % check limits
        update_ui_str(hObject, tmp); %% update edit box 
        handles.v.DB = tmp;
        % update handles structure
        guidata(hObject, handles);
    else
        update_ui_str(hObject, handles.v.DB);
    end
%--------------------------------------------------------------------------
function checkResumeMean_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Resume Mean checkbox clicked';
    set(handles.textMessage, 'String', str);
    % update corresponding variable 
    handles.v.Mean = read_ui_val(hObject); 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
function radioFilterType_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '* Filter Type changed';
    set(handles.textMessage, 'String', str);
    % get selected value 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioLP'
            % show message 
            str = 'Low Pass filter selected';
            set(handles.textMessage, 'String', str);
            % set Filt flag
            handles.v.Filt = 'LP'; 
            % update UI
            disable_ui(handles.editF1);
            enable_ui(handles.editF2);
        case 'radioHP'
            % show message 
            str = 'High Pass filter selected';
            set(handles.textMessage, 'String', str);
            % set Filt flag
            handles.v.Filt = 'HP'; 
            % update UI
            enable_ui(handles.editF1);
            disable_ui(handles.editF2);
        case 'radioBP'
            % show message 
            str = 'Band Pass filter selected';
            set(handles.textMessage, 'String', str);
            % set Filt flag
            handles.v.Filt = 'BP'; 
            % update UI
            enable_ui(handles.editF1);
            enable_ui(handles.editF2);
        case 'radioBS'
            % show message 
            str = 'Band Stop filter selected';
            set(handles.textMessage, 'String', str);
            % set Filt flag
            handles.v.Filt = 'BS'; 
            % update UI
            enable_ui(handles.editF1);
            enable_ui(handles.editF2);
        case 'radioNO'
            % show message 
            str = 'No filter selected';
            set(handles.textMessage, 'String', str);
            % set Filt flag
            handles.v.Filt = 'NO'; 
            % update UI
            disable_ui(handles.editF1);
            disable_ui(handles.editF2);
    end
    % update handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Spike Detect panel callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonApplyTh_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Apply Threshold button pressed';
    set(handles.textMessage, 'String', str);
    % prepare useful variables
    inFs = handles.v.inFs;
    nmax = handles.v.nstims; 
    a_start = ms2samples(handles.v.Start, inFs);  
    a_end   = ms2samples(handles.v.End,   inFs);     
    dwin   = ms2samples(handles.v.Window, inFs);
    acqp = ms2samples(handles.d.curvesettings.tdt.AcqDuration, inFs);
    tvec = 1000*(0:acqp-1)/inFs; % (ms)
    % prepare storage variables
    handles.a.spike_idx    = cell(handles.v.ntrials,handles.v.nreps);
    handles.a.spike_times  = cell(handles.v.ntrials,handles.v.nreps);
    handles.a.spike_counts = zeros(handles.v.ntrials,handles.v.nreps);
    % determine threshold 
    if handles.v.ThAuto
        if a_start>0
            spontSD = zeros(1,nmax);
            for i=1:nmax
                sponttrace = handles.d.filteresp{i}(1:a_start);
                spontSD(i) = std(sponttrace);
            end
            refSD = mean(spontSD);
        else
            refSD = 0;
        end
        thval = refSD * handles.v.ThresSD * handles.v.Sign;
    else % manual threshold: param.Scale [V] -> thval [V]
        thval = handles.v.Threshold * handles.v.Scale * handles.v.Sign; 
    end
    % store and show threshold
    handles.v.thval = thval;
    if thval > 0.1 % large thval
        str = sprintf('%.2f [mV]',thval*1000);    
    elseif thval > 0.001 % medium thval
        str = sprintf('%.3f [mV]',thval*1000);
    else 
        str = sprintf('%.4f [mV]',thval*1000);
    end
    set(handles.textThreshold, 'String', str); 
    % apply threshold : algorithm taken from HPSearch2a_spikedetect.m
    for i=1:nmax
        resp = handles.d.filteresp{i}'; 
        idx = [];
        % peak detection
        r1 = [ resp(1), resp(1:end-1) ]; % shifted forward
        r9 = [ resp(2:end), resp(end) ]; % shifted backward
        idxp = ( (r1<resp) & (r9<resp) & (thval<resp) ); % peak timings 
        idxb = ( (r1>resp) & (r9>resp) & (thval>resp) ); % bottom timings
        % use peak or bottom according to the Peak setting
        if handles.v.Peak < 0  % use bottom
            idx = idxb;
        elseif handles.v.Peak > 0 % use peak
            idx = idxp;
        elseif thval < 0 % use bottom
            idx = idxb;
        else % use peak 
            idx = idxp; 
        end
        % deleting doublets 
        if dwin > 0
            a = conv(1*idx, [ ones(1,dwin-1), 0] );
            b = a(dwin:end);
            c = ~(b>0);  % make rejection window
            idx = idx & c; 
        end
        % calculating spike rate within the analysis window
        a_idx = [ zeros(1,a_start) ones(1,a_end-a_start), zeros(1,length(idx)-a_end) ]; 
        a_spidx = idx & a_idx(1:length(idx));
        a_nspike = sum(a_spidx); % number of spikes within the analysis window
        % store results
        handles.a.spike_idx{i} = idx;
        handles.a.spike_times{i} = tvec(idx);
        handles.a.spike_counts(i) = a_nspike;
    end
    % spike detection info
    handles.a.analysis = struct();
    handles.a.analysis.WindowWidth = handles.v.Window; 
    handles.a.analysis.StartTime = handles.v.Start;
    handles.a.analysis.EndTime = handles.v.End;
    handles.a.analysis.ThresSD = handles.v.ThresSD;
    handles.a.analysis.Raster = 0;
    handles.a.analysis.limits = struct();
    handles.a.analysis.ThAuto = handles.v.ThAuto;
    handles.a.analysis.Peak = handles.v.Threshold;
    handles.a.analysis.Sign = handles.v.Sign;
    handles.a.analysis.Scale = handles.v.Scale;
    handles.a.analysis.Threshold = handles.v.thval;
    % set the flag
    handles.f.threshold = 1;
    % update handles structure
    guidata(hObject, handles);
    % plot waveforms
    TytoSpan_Plot;
%--------------------------------------------------------------------------
function radioThreshold_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '* Threshold Auto/Manual changed';
    set(handles.textMessage, 'String', str);
    % get selected value 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioThAuto'
            % show message 
            str = 'Auto Threshold selected';
            set(handles.textMessage, 'String', str);
            % set ThAuto flag
            handles.v.ThAuto = 1; 
            % update UI
            enable_ui(handles.editAutoTh);
            disable_ui(handles.sliderManualTh);
            disable_ui(handles.editManualTh);
            disable_ui(handles.radioScale0);
            disable_ui(handles.radioScale1);
            disable_ui(handles.radioScale2);
            disable_ui(handles.radioScale3);
            disable_ui(handles.radioScale4);
            disable_ui(handles.radioScale5);
%            disable_ui(handles.radioThPlus);
%            disable_ui(handles.radioThMinus);
        case 'radioThManual'
            % show message 
            str = 'Manual Threshold selected';
            set(handles.textMessage, 'String', str);
            % reset ThAuto flag
            handles.v.ThAuto = 0; 
            % update UI
            disable_ui(handles.editAutoTh);
            enable_ui(handles.sliderManualTh);
            enable_ui(handles.editManualTh);
            enable_ui(handles.radioScale0);
            enable_ui(handles.radioScale1);
            enable_ui(handles.radioScale2);
            enable_ui(handles.radioScale3);
            enable_ui(handles.radioScale4);
            enable_ui(handles.radioScale5);
%            enable_ui(handles.radioThPlus);
%            enable_ui(handles.radioThMinus);
    end
    % update handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function radioDetection_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '* Threshold Detection changed';
    set(handles.textMessage, 'String', str);
    % get selected value 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioPeakAuto'
            % show message 
            str = 'Auto peak detection selected';
            set(handles.textMessage, 'String', str);
            % set Peak flag
            handles.v.Peak = 0; 
        case 'radioPeakTop'
            % show message 
            str = 'Top detection selected';
            set(handles.textMessage, 'String', str);
            % set Peak flag
            handles.v.Peak = 1; 
        case 'radioPeakBottom'
            % show message 
            str = 'Bottom detection selected';
            set(handles.textMessage, 'String', str);
            % set Peak flag
            handles.v.Peak = -1; 
    end
    % update handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editAutoTh_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Auto Threshold level changed';
    set(handles.textMessage, 'String', str);
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [-100 100]) % check limits
        handles.v.ThresSD = tmp;
        guidata(hObject, handles); % update handles structure
    else % resetting to old value
        update_ui_str(hObject, handles.h2.analysis.ThresSD);
    end
%--------------------------------------------------------------------------
function editWindow_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Rejection Window Size changed';
    set(handles.textMessage, 'String', str);
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0 10000]) % check limits
        handles.v.Window = tmp;
        guidata(hObject, handles); % update handles structure
    else % resetting to old value
        update_ui_str(hObject, handles.v.Window);
    end
function editStart_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Analysis Start Time changed';
    set(handles.textMessage, 'String', str);
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0 10000]) % check limits
        handles.v.Start = tmp;
        guidata(hObject, handles); % update handles structure
    else % resetting to old value
        update_ui_str(hObject, handles.v.Start);
    end
function editEnd_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Analysis End Time changed';
    set(handles.textMessage, 'String', str);
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0 10000]) % check limits
        handles.v.End = tmp;
        guidata(hObject, handles); % update handles structure
    else % resetting to old value
        update_ui_str(hObject, handles.v.End);
    end
%--------------------------------------------------------------------------
function sliderManualTh_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Manual Threshold slider changed';
    set(handles.textMessage, 'String', str);
    % update corresponding edit box
    handles.v.Threshold = ...
        slider_update(handles.sliderManualTh, handles.editManualTh, '%.1f');
    % update handles structure
    guidata(hObject, handles); 
function editManualTh_Callback(hObject, eventdata, handles)
    % show message 
    str = '* Manual Threshold level changed';
    set(handles.textMessage, 'String', str);
    % update corresponding slider 
    handles.v.Threshold = ...
        text_update(handles.editManualTh, handles.sliderManualTh, ...
                    [0.5 20.5], '%.1f');
    % update handles structure
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
function radioScale_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '* Threshold Scale changed';
    set(handles.textMessage, 'String', str);
    % get selected value 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioScale0'
            str = '1000 mV (1 V) selected';
            set(handles.textMessage, 'String', str);
            handles.v.Scale = 1.0; 
        case 'radioScale1'
            str = '100 mV (0.1 V) selected';
            set(handles.textMessage, 'String', str);
            handles.v.Scale = 1.0e-1; 
        case 'radioScale2'
            str = '10 mV (0.01 V) selected';
            set(handles.textMessage, 'String', str);
            handles.v.Scale = 1.0e-2; 
        case 'radioScale3'
            str = '1 mV (0.001 V) selected';
            set(handles.textMessage, 'String', str);
            handles.v.Scale = 1.0e-3; 
        case 'radioScale4'
            str = '0.1 mV (100 uV) selected';
            set(handles.textMessage, 'String', str);
            handles.v.Scale = 1.0e-4; 
        case 'radioScale5'
            str = '0.01 mV (10 uV) selected';
            set(handles.textMessage, 'String', str);
            handles.v.Scale = 1.0e-5; 
    end
    % update handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function radioSign_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '* Threshold Sign changed';
    set(handles.textMessage, 'String', str);
    % get selected value 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioThPlus'
            str = 'Positive Threshold selected';
            set(handles.textMessage, 'String', str);
            handles.v.Sign = 1.0; 
        case 'radioThMinus'
            str = 'Negative Threshold selected';
            set(handles.textMessage, 'String', str);
            handles.v.Sign = -1.0; 
    end
    % update handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editP1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editP2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editP3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editP4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editP5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editF1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editF2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFdim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editManualTh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderManualTh_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function editAutoTh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editWindow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editStart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editEnd_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------



