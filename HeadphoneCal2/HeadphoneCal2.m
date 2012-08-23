function varargout = HeadphoneCal2(varargin)
%HEADPHONECAL2 M-file for HeadphoneCal2.fig
%   HEADPHONECAL2, by itself, creates a new HEADPHONECAL2 or raises the existing singleton*.
%
%   H = HEADPHONECAL2 returns the handle to a new HEADPHONECAL2 or the handle to
%      the existing singleton*.

% Last Modified by GUIDE v2.5 09-May-2012 12:50:37

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%   sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version Written (MicrophoneCal): 2009-2011 by SJS
% Upgraded Version Written (MicrophoneCal2): 2011-2012 by GA
%--------------------------------------------------------------------------
% ** Important Notes ** (Nov 2011, GA)
%   Parameters used in HeadphoneCal2 are stored under the handles.h2 structure,
%   while parameters used in HeadphoneCal are stored directly under handles. 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization code automatically created by the Matlab GUIDE function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Begin initialization code - DO NOT EDIT
%--------------------------------------------------------------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HeadphoneCal2_OpeningFcn, ...
                   'gui_OutputFcn',  @HeadphoneCal2_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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
% --- Executes just before HeadphoneCal2 is made visible.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function HeadphoneCal2_OpeningFcn(hObject, eventdata, handles, varargin)
    % display message
    str = 'HeadphoneCal2 opening function called';
    set(handles.textMessage, 'String', str);
    % initialize handles.h2 structure
    handles.h2 = struct();
    % setting defaults
    handles.h2.defaults = HeadphoneCal2_init('INIT');
    % setting current cal settings
    handles.h2.cal = handles.h2.defaults;
    % default hardware is 'No_TDT' 
    handles.h2.config = HeadphoneCal2_init('NO_TDT');
    % current fr settings is empty
    handles.h2.fr.loadedL = 0;
    handles.h2.fr.loadedR = 0;
    % resetting COMPLETE flag -- calibration is incomplete
    handles.h2.COMPLETE = 0;
    % resetting ABORT flag
    handles.h2.ABORT = 0;
    % save handles struture		
    guidata(hObject, handles);
    % updating the GUI
    HeadphoneCal2_updateUI
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function varargout = HeadphoneCal2_OutputFcn(hObject, eventdata, handles)
    % Set default command line output 
    varargout{1} = hObject;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Cleaning up before closing 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function CloseRequestFcn(hObject, eventdata, handles)
    pause(0.1);
	delete(hObject);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup menu for selecting TDT hardware 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function popupTDT_Callback(hObject, eventdata, handles)
    % reading out selected hardware
    tdtStrings = read_ui_str(hObject);  % list of strings
    selectedVal = read_ui_val(hObject); % selected item number
    selectedStr = upper(tdtStrings{selectedVal}); % selected item
    % display message
    str = [ selectedStr ' selected' ];
    set(handles.textMessage, 'String', str);
    % update handles.h2.config according to the selection of TDT
    handles.h2.config = HeadphoneCal2_init(selectedStr);
	guidata(hObject, handles); 
    % updating the GUI
    HeadphoneCal2_updateUI
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save/Load Settings button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveSettings_Callback(hObject, eventdata, handles)
    % get file name
	[fname, fpath] = ...
        uiputfile('*_HPCal2settings.mat', 'Save HeadphoneCal2 settings file...');
	if fname == 0 % return if user hits CANCEL button
		str = 'saving cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % display message
    str = ['Saving settings to ' fname]; 
    set(handles.textMessage, 'String', str);
	% save cal data
    cal = handles.h2.cal; 
	save(fullfile(fpath, fname), '-MAT', 'cal');
%--------------------------------------------------------------------------
function buttonLoadSettings_Callback(hObject, eventdata, handles)
    % get file name
	[fname, fpath] = ...
        uigetfile('*_HPCal2settings.mat', 'Load HeadphoneCal2 settings file...');
	if fname == 0 % return if user hits CANCEL button
		str = 'loading cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % display message
    str = ['Loading settings from ' fname]; 
    set(handles.textMessage, 'String', str);
	% load cal data
	load(fullfile(fpath, fname), 'cal');
	handles.h2.cal = cal;
	handles.h2.COMPLETE = 0; % calibration with these settings is incomplete
	guidata(hObject, handles); % save handles structure 
    % updating the GUI
    HeadphoneCal2_updateUI; 
%--------------------------------------------------------------------------
function buttonDefaultSettings_Callback(hObject, eventdata, handles)
    % display message
    str = 'loading default settings...'; 
    set(handles.textMessage, 'String', str);
    % load the default settings
    handles.h2.cal = handles.h2.defaults;
    handles.h2.COMPLETE = 0; % calibration with these settings is incomplete
    guidata(hObject, handles); % save handles structure 
    % updating the GUI
    HeadphoneCal2_updateUI;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FR Load button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonLoadFRL_Callback(hObject, eventdata, handles)
    % get file name
	[fname, fpath] = ...
        uigetfile('*_fr2.mat', 'Load FR data for LEFT microphone...');
	if fname == 0 % return if user hits CANCEL button
		str = 'loading cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % display message
    str = ['Loading LEFT microphone calibration data from ' fname];
    set(handles.textMessage, 'String', str);
	% load FR data
    handles.h2.fr.frfileL = fullfile(fpath, fname);
	load(handles.h2.fr.frfileL, 'frdata');
    handles.h2.fr.frdataL = frdata;
    handles.h2.fr.loadedL = 1;
	handles.h2.COMPLETE = 0; % calibration with these settings is incomplete
    guidata(hObject, handles); % save handles structure
    % show the file name
	update_ui_str(handles.textFRL, handles.h2.fr.frfileL);
%--------------------------------------------------------------------------
function buttonLoadFRR_Callback(hObject, eventdata, handles)
    % get file name
	[fname, fpath] = ...
        uigetfile('*_fr2.mat', 'Load FR data for RIGHT microphone...');
	if fname == 0 % return if user hits CANCEL button
		str = 'loading cancelled...';
        set(handles.textMessage, 'String', str);
		return;
    end
    % display message
    str = ['Loading RIGHT microphone calibration data from ' fname];
    set(handles.textMessage, 'String', str);
	% load FR data
    handles.h2.fr.frfileR = fullfile(fpath, fname);
	load(handles.h2.fr.frfileR, 'frdata');
    handles.h2.fr.frdataR = frdata;
    handles.h2.fr.loadedR = 1;
	handles.h2.COMPLETE = 0; % calibration with these settings is incomplete
    guidata(hObject, handles); % save handles structure
    % show the file name
	update_ui_str(handles.textFRR, handles.h2.fr.frfileR);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action button (Calibrate, Abort) callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonCalibrate_Callback(hObject, eventdata, handles)
    % display message
    str = 'Starting Calibration'; 
    set(handles.textMessage, 'String', str);
    % updating buttons 
    disable_ui(handles.buttonCalibrate);
    enable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0);
    % resetting COMPLETE flag
    handles.h2.COMPLETE = 0;
    % resetting ABORT flag
    handles.h2.ABORT = 0;
    % save handles structure
    guidata(hObject, handles);
    % go to main part
    HeadphoneCal2_Run;
    % updating buttons 
    enable_ui(handles.buttonCalibrate);
    disable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0); 
    % if completed then plot data
    if handles.h2.COMPLETE
        HeadphoneCal2_plot(handles.h2.caldata);
    end
    % save handles structure
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function buttonAbort_Callback(hObject, eventdata, handles)
    % display message
    str = 'ABORT button pressed'; 
    set(handles.textMessage, 'String', str);
    % disable button -- Abort button should not be pressed more than once 
    disable_ui(hObject); 
    % save handles structure
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot button callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonPlotCAL_Callback(hObject, eventdata, handles)
    % get file name 
    [fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load HeadPhoneCal2 data file...');
    if fname == 0 % return if user hits CANCEL button
        str = 'Loading cancelled...'; 
        set(handles.textMessage, 'String', str);
        return;
    end
    % load data
    c = load(fullfile(fpath, fname));
    % check if loaded data is a structure
    if ~isstruct(c)
        str = 'Warning: invalid HeadphoneCal2 data file'; 
        set(handles.textMessage, 'String', str);
        return; 
    end
    % check whether frdata field exists
    if ~isfield(c,'caldata')
        str = 'Warning: invalid HeadphoneCal2 data file -- caldata does not exist'; 
        set(handles.textMessage, 'String', str);
        return; 
    end
    % display message
    str = ['Loaded data from ' fname ];
    set(handles.textMessage, 'String', str);
    % plot CAL data
    HeadphoneCal2_plot(c.caldata, fname);
%--------------------------------------------------------------------------
function buttonPlotFR_Callback(hObject, eventdata, handles)
    if ~handles.h2.fr.loadedL && ~handles.h2.fr.loadedR
        % display message
        str = 'No FR files loaded';
        set(handles.textMessage, 'String', str);
        return;
    end
    % display message
    str = 'Plotting FR data';
    set(handles.textMessage, 'String', str);
    % plot LEFT FR data
    if handles.h2.fr.loadedL
        MicrophoneCal2_plot(handles.h2.fr.frdataL, 'Left FR');
    end
    % plot RIGHT FR data
    if handles.h2.fr.loadedR
        MicrophoneCal2_plot(handles.h2.fr.frdataR, 'Right FR');
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SaveRawData checkbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function checkSaveRawData_Callback(hObject, eventdata, handles)
    % reading the check box
    handles.h2.cal.SaveRawData = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.cal.SaveRawData
        str = 'Raw Data will be saved';
    else
        str = 'Raw Data will not be saved';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for TDT hardware settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editOutChanL_Callback(hObject, eventdata, handles)
    % display message
    str = 'Output Channel L changed';
    set(handles.textMessage, 'String', str);
    % update val
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.OutChanL = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editOutChanR_Callback(hObject, eventdata, handles)
    % display message
    str = 'Output Channel R changed';
    set(handles.textMessage, 'String', str);
    % update val
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.OutChanR = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editInChanL_Callback(hObject, eventdata, handles)
    % display message
    str = 'Input Channel L changed';
    set(handles.textMessage, 'String', str);
    % update val
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.InChanL = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editInChanR_Callback(hObject, eventdata, handles)
    % display message
    str = 'Input Channel R changed';
    set(handles.textMessage, 'String', str);
    % update val
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.InChanR = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for microphone settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editGainL_Callback(hObject, eventdata, handles)
    % display message
    str = 'Gain L changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 120]) 
		handles.h2.cal.MicGainL_dB = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MicGainL_dB);
    end
%--------------------------------------------------------------------------
function editGainR_Callback(hObject, eventdata, handles)
    % display message
    str = 'Gain R changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 120]) 
		handles.h2.cal.MicGainR_dB = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MicGainR_dB);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes/radiobuttons/checkbox for calibration settings   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editFmin_Callback(hObject, eventdata, handles)
    % display message
    str = 'Fmin changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0, handles.h2.cal.Fmax]) 
		handles.h2.cal.Fmin = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Fmin);
    end
%--------------------------------------------------------------------------
function editFmax_Callback(hObject, eventdata, handles)
    % display message
    str = 'Fmax changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [handles.h2.cal.Fmin, 20000]) 
		handles.h2.cal.Fmax = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Fmax);
    end
%--------------------------------------------------------------------------
function editFstep_Callback(hObject, eventdata, handles)
    % display message
    str = 'Fstep changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [1, 20000]) 
		handles.h2.cal.Fstep = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Fstep);
    end
%--------------------------------------------------------------------------
function editReps_Callback(hObject, eventdata, handles)
    % display message
    str = 'Reps changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [1, 100]) 
		handles.h2.cal.Reps = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Reps);
    end
%--------------------------------------------------------------------------
function radioSide_SelectionChangeFcn(hObject, eventdata, handles)
    % check selected val 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioBoth'
            % display message
            str = 'Both selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.Side = 'BOTH'; 
            guidata(hObject, handles);
        case 'radioLeft'
            % display message
            str = 'Left selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.Side = 'LEFT'; 
            guidata(hObject, handles);
        case 'radioRight'
            % display message
            str = 'Right selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.Side = 'RIGHT'; 
            guidata(hObject, handles);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes/radiobuttons for attenuation settings   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editMinLevel_Callback(hObject, eventdata, handles)
    % display message
    str = 'Min Level changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0, handles.h2.cal.MaxLevel-1]) 
		handles.h2.cal.MinLevel = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MinLevel);
    end
%--------------------------------------------------------------------------
function editMaxLevel_Callback(hObject, eventdata, handles)
    % display message
    str = 'Max Level changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [handles.h2.cal.MinLevel+1 100])	
		handles.h2.cal.MaxLevel = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MaxLevel);
    end
%--------------------------------------------------------------------------
function editAttenStep_Callback(hObject, eventdata, handles)
    % display message
    str = 'Atten Step changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [1 handles.h2.cal.MaxLevel-handles.h2.cal.MinLevel]) 
		handles.h2.cal.AttenStep = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.AttenStep);
    end
%--------------------------------------------------------------------------
function editAttenFixed_Callback(hObject, eventdata, handles)
    % display message
    str = 'Atten changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 120]) 
		handles.h2.cal.AttenFixed = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.AttenFixed);
    end
%--------------------------------------------------------------------------
function radioAtten_SelectionChangeFcn(hObject, eventdata, handles)
    % check selected val 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioAttenVaried'
            % display message
            str = 'fixed dB SPL selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.AttenType = 'VARIED'; 
            guidata(hObject, handles);
            % enable/disable editboxes
            enable_ui(handles.editMinLevel);
            enable_ui(handles.editMaxLevel);
            enable_ui(handles.editAttenStep);
            disable_ui(handles.editAttenFixed);             
        case 'radioAttenFixed'
            str = 'fixed attenuation selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.AttenType = 'FIXED'; 
            guidata(hObject, handles);
            % enable/disable editboxes
            disable_ui(handles.editMinLevel);
            disable_ui(handles.editMaxLevel);
            disable_ui(handles.editAttenStep);
            enable_ui(handles.editAttenFixed);             
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for stimulus settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editISI_Callback(hObject, eventdata, handles)
    % display message
    str = 'ISI changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [1, 1000]) 
        handles.h2.cal.ISI = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.ISI);
    end
%--------------------------------------------------------------------------
function editDuration_Callback(hObject, eventdata, handles)
    % display message
    str = 'Duration changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [handles.h2.cal.Ramp*2+10, 1000]) 
        handles.h2.cal.Duration = tmp;
        % update AcqDuration and SweepPeriod
        tmplength = handles.h2.cal.Duration + handles.h2.cal.Delay + 10; 
        handles.h2.cal.AcqDuration = ceil(tmplength/50)*50;
        handles.h2.cal.SweepPeriod = handles.h2.cal.AcqDuration + 10;
        update_ui_str(handles.editAcqDuration, handles.h2.cal.AcqDuration);
        update_ui_str(handles.editSweepPeriod, handles.h2.cal.SweepPeriod);
        % save data
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.Duration);
    end
%--------------------------------------------------------------------------
function editDelay_Callback(hObject, eventdata, handles)
    % display message
    str = 'Delay changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0, 1000]) 
        handles.h2.cal.Delay = tmp;
        % update AcqDuration and SweepPeriod
        tmplength = handles.h2.cal.Duration + handles.h2.cal.Delay + 10; 
        handles.h2.cal.AcqDuration = ceil(tmplength/50)*50;
        handles.h2.cal.SweepPeriod = handles.h2.cal.AcqDuration + 10;
        update_ui_str(handles.editAcqDuration, handles.h2.cal.AcqDuration);
        update_ui_str(handles.editSweepPeriod, handles.h2.cal.SweepPeriod);
        % save data
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.Delay);
    end
%--------------------------------------------------------------------------
function editRamp_Callback(hObject, eventdata, handles)
    % display message
    str = 'Ramp changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0, (handles.h2.cal.Duration-10)/2.0]) 
        handles.h2.cal.Ramp = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.Ramp);
    end
%--------------------------------------------------------------------------
function editDAlevel_Callback(hObject, eventdata, handles)
    % display message
    str = 'DAlevel changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0, 10]) 
        handles.h2.cal.DAlevel = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.DAlevel);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for TDT settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editAcqDuration_Callback(hObject, eventdata, handles)
    % display message
    str = 'Warning: AcqDuration is not editable';
    set(handles.textMessage, 'String', str);
    % resetting to old value
    update_ui_str(hObject, handles.h2.cal.AcqDuration);
%--------------------------------------------------------------------------
function editSweepPeriod_Callback(hObject, eventdata, handles)
    % display message
    str = 'Warning: SweepPeriod is not editable';
    set(handles.textMessage, 'String', str);
    % resetting to old value
    update_ui_str(hObject, handles.h2.cal.SweepPeriod);
%--------------------------------------------------------------------------
function editTTLPulseDur_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0, 100])    % check limits
        handles.h2.cal.Ramp = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.TTLPulseDur);
    end
%--------------------------------------------------------------------------
function editHPFreq_Callback(hObject, eventdata, handles)
    % display message
    str = 'HP Freq changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [1, handles.h2.cal.LPFreq]) 
        handles.h2.cal.HPFreq = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.HPFreq);
    end
%--------------------------------------------------------------------------
function editLPFreq_Callback(hObject, eventdata, handles)
    % display message
    str = 'LP Freq changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [handles.h2.cal.HPFreq, 25000]) 
        handles.h2.cal.LPFreq = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.LPFreq);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for results --- editing these boxes has no effects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editFreqVal_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editRepVal_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editAttenL_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editValL_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editSPLL_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editAttenR_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editValR_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editSPLR_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editFmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFstep_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editReps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editMinLevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editMaxLevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAttenStep_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAttenFixed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editGainL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editGainR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function popupTDT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editOutChanL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editOutChanR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editInChanL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editInChanR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editISI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDelay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRamp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDAlevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editAcqDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSweepPeriod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editTTLPulseDur_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editHPFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editLPFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editFreqVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRepVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAttenL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editValL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSPLL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editValR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSPLR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAttenR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------

