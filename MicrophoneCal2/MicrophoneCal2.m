function varargout = MicrophoneCal2(varargin)
%MICROPHONECAL2 M-file for MicrophoneCal2.fig
%   MICROPHONECAL2, by itself, creates a new MICROPHONECAL2 or raises the existing singleton*.
%
%   H = MICROPHONECAL2 returns the handle to a new MICROPHONECAL2 or the handle to
%      the existing singleton*.

% Last Modified by GUIDE v2.5 03-May-2012 10:29:48

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%   sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version Written (MicrophoneCal): 2009-2011 by SJS
% Upgraded Version Written (MicrophoneCal2): 2011-2012 by GA
%--------------------------------------------------------------------------
% ** Important Notes ** (Nov 2011, GA)
%   Parameters used in MicrophoneCal2 are stored under the handles.h2 structure,
%   while parameters used in MicrophoneCal are stored directly under handles. 
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
                   'gui_OpeningFcn', @MicrophoneCal2_OpeningFcn, ...
                   'gui_OutputFcn',  @MicrophoneCal2_OutputFcn, ...
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
% --- Executes just before MicrophoneCal2 is made visible.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function MicrophoneCal2_OpeningFcn(hObject, eventdata, handles, varargin)
    % display message
    str = 'MicrophoneCal2 opening function called';
    set(handles.textMessage, 'String', str);
    % initialize handles.h2 structure
    handles.h2 = struct();
    % setting defaults 
    handles.h2.defaults = MicrophoneCal2_init('INIT');
    % setting current cal settings
    handles.h2.cal = handles.h2.defaults;
    % default hardware is 'No_TDT' 
    handles.h2.config = MicrophoneCal2_init('NO_TDT');
    % resetting COMPLETE flag -- calibration is incomplete
    handles.h2.COMPLETE = 0;
    % resetting ABORT flag 
    handles.h2.ABORT = 0;
    % load the BK mic pressure field data
    BKPressureFile = 'W2495529.BKW';
    handles.h2.bkdata = readBKW(BKPressureFile);
    % save handles struture 
    guidata(hObject, handles);
    % updating the GUI
    MicrophoneCal2_updateUI
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function varargout = MicrophoneCal2_OutputFcn(hObject, eventdata, handles)
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
    handles.h2.config = MicrophoneCal2_init(selectedStr);
	guidata(hObject, handles); 
    % updating the GUI
    MicrophoneCal2_updateUI
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save/Load Settings button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveSettings_Callback(hObject, eventdata, handles)
    % get file name
    [fname, fpath] = ...
        uiputfile('*_MicCal2settings.mat', 'Save MicrophoneCal2 settings file...');
    if fname == 0  % return if user hits CANCEL button
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
        uigetfile('*_MicCal2settings.mat', 'Load MicrophoneCal2 settings file...'); 
    if fname == 0  % return if user hits CANCEL button
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
    MicrophoneCal2_updateUI;
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
    MicrophoneCal2_updateUI
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
    MicrophoneCal2_Run;
    % updating buttons 
    enable_ui(handles.buttonCalibrate);
    disable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0); 
    % if completed then plot data
    if handles.h2.COMPLETE
        MicrophoneCal2_plot(handles.h2.frdata);
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
function buttonPlotFR_Callback(hObject, eventdata, handles)
    % get file name 
    [fname, fpath] = ...
        uigetfile('*_fr2.mat', 'Load MicroPhoneCal2 data file...');
    if fname == 0 % return if user hits CANCEL button
        str = 'Loading cancelled...'; 
        set(handles.textMessage, 'String', str);
        return;
    end
    % load data
    c = load(fullfile(fpath, fname));
    % check if loaded data is a structure
    if ~isstruct(c)
        str = 'Warning: invalid MicrophoneCal2 data file'; 
        set(handles.textMessage, 'String', str);
        return; 
    end
    % check whether frdata field exists
    if ~isfield(c,'frdata')
        str = 'Warning: invalid MicrophoneCal2 data file -- frdata does not exist'; 
        set(handles.textMessage, 'String', str);
        return; 
    end
    % display message
    str = ['Loaded data from ' fname ];
    set(handles.textMessage, 'String', str);
    % plot FR data
    MicrophoneCal2_plot(c.frdata, fname);
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
function editOutChannel_Callback(hObject, eventdata, handles)
    % display message
    str = 'Output Channel changed';
    set(handles.textMessage, 'String', str);
    % update val
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.config.OutChannel = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editRefChannel_Callback(hObject, eventdata, handles)
    % display message
    str = 'Ref Channel changed';
    set(handles.textMessage, 'String', str);
    % update val
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.config.RefChannel = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editMicChannel_Callback(hObject, eventdata, handles)
    % display message
    str = 'Mic Channel changed';
    set(handles.textMessage, 'String', str);
    % update val
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.config.MicChannel = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for calibration settings 
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
function editAtten_Callback(hObject, eventdata, handles)
    % display message
    str = 'Atten changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [0, 120]) 
        handles.h2.cal.Atten = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.Atten);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes and radio buttons for microphone settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function editRefMicSens_Callback(hObject, eventdata, handles)
    % display message
    str = 'Ref Mic Sensitivity changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, [1e-9, 1000]) 
        handles.h2.cal.RefMicSens = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.cal.RefMicSens);
    end
%--------------------------------------------------------------------------
function editRefGain_Callback(hObject, eventdata, handles)
    % display message
    str = 'Ref Gain changed';
    set(handles.textMessage, 'String', str);
    % update val 
    handles.h2.cal.RefGain_dB = read_ui_str(hObject, 'n'); 
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editMicGain_Callback(hObject, eventdata, handles)
    % display message
    str = 'Mic Gain changed';
    set(handles.textMessage, 'String', str);
    % update val 
    handles.h2.cal.MicGain_dB = read_ui_str(hObject, 'n'); 
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function radioFieldType_SelectionChangeFcn(hObject, eventdata, handles)
    % check selected val 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioPressure'
            % display message
            str = 'Pressure Field selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.FieldType = 'PRESSURE'; 
            guidata(hObject, handles);
        case 'radioFree'
            % display message
            str = 'Free Field selected';
            set(handles.textMessage, 'String', str);
            % update val 
            handles.h2.cal.FieldType = 'FREE'; 
            guidata(hObject, handles);
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
function editRefVal_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editRefSPL_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editMicVal_Callback(hObject, eventdata, handles)
    update_ui_str(hObject, '--');  % resetting to '--'
%--------------------------------------------------------------------------
function editMicSPL_Callback(hObject, eventdata, handles)
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
function editAtten_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editDAlevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRefMicSens_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRefGain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editMicGain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function popupTDT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editOutChannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRefChannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editMicChannel_CreateFcn(hObject, eventdata, handles)
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
function editRefVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRefSPL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editMicVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editMicSPL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------

