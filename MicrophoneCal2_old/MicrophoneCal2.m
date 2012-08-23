function varargout = MicrophoneCal2(varargin)
%MICROPHONECAL2 M-file for MicrophoneCal2.fig
%   MICROPHONECAL2, by itself, creates a new MICROPHONECAL2 or raises the existing singleton*.
%
%   H = MICROPHONECAL2 returns the handle to a new MICROPHONECAL2 or the handle to
%      the existing singleton*.

%  MicrophoneCal was originally written by Sharad J Shanbhag in 2009-2011. 
%  Based on MicrophoneCal, this modified version named MicrophoneCal2 
%  was written by Go Ashida in Nov 2011.

% Last Modified by GUIDE v2.5 07-Nov-2011 11:12:29

%--------------------------------------------------------------------------
% ** Important Notes ** (Nov 2011, GA)
%   Parameters used in MicrophoneCal2 are stored under the handles.h2 structure,
%   while parameters used in MicrophoneCal are stored directly under handles. 
%
%
%

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
    handles.h2 = struct();
    % setting defaults
    handles.h2.DefaultType = MicrophoneCal2_init('INIT');
    handles.h2.defaults = MicrophoneCal2_init(handles.h2.DefaultType);
    % setting current cal settings
    handles.h2.cal = handles.h2.defaults;
    % calibration is incomplete
    handles.h2.COMPLETE = 0;
    % resetting ABORT flag
    handles.h2.ABORT = 0;
    % Choose default command line output for MicrophoneCal2
    handles.output = hObject;
    % load the BK mic pressure field data
    BKPressureFile = 'W2495529.BKW';
    handles.h2.cal.bkdata = readBKW(BKPressureFile);
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
% Get default command line output from handles structure
varargout{1} = handles.output;
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
% Action button (Calibrate, Abort) callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonCalibrate_Callback(hObject, eventdata, handles)
    % updating buttons 
    disable_ui(handles.buttonCalibrate);
    enable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0);
    % resetting COMPLETE flag
    handles.h2.COMPLETE = 0;
    COMPLETE = 0;
    guidata(hObject, handles);
	
    MicrophoneCal2_Run;
    % pause(2); COMPLETE = 1;  % for testing/debugging
    
    % updating buttons 
    enable_ui(handles.buttonCalibrate);
    disable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0);
    if COMPLETE
    	handles.h2.COMPLETE = 1;
        enable_ui(handles.buttonSaveFR);
        enable_ui(handles.buttonSaveRaw);
        enable_ui(handles.buttonPlotFR);
        MicrophoneCal2_plot(handles.h2.frdata);
    end
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function buttonAbort_Callback(hObject, eventdata, handles)
%	disp('ABORTING Calibration!')
	handles.h2.ABORT = 1;
	handles.h2.ABORT
	guidata(hObject, handles);	
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save/Plot button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveFR_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uiputfile('*_fr2.mat', 'Save MicrophoneCal2 calibration data file...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('saving cancelled...');
		return;
    end
	% save cal data
    disp(['Saving microphone calibration data to ' fname])
    frdata = handles.h2.frdata; 
	save(fullfile(fpath, fname), '-MAT', 'frdata');
%--------------------------------------------------------------------------
function buttonSaveRaw_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uiputfile('*.mat', 'Save MicrophoneCal2 raw data file...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('saving cancelled...');
		return;
    end
	% save cal data
    disp(['Saving microphone calibration raw data to ' fname])
    rawdata = handles.h2.rawdata; 
    frdata = handles.h2.frdata; 
    cal = handles.h2.cal; 
	save(fullfile(fpath, fname), '-MAT', 'rawdata', 'frdata', 'cal');
%--------------------------------------------------------------------------
function buttonPlotFR_Callback(hObject, eventdata, handles)
	if ~isfield(handles.h2, 'frdata') 
		return;
    end
    MicrophoneCal2_plot(handles.h2.frdata);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveSettings_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uiputfile('*_MicCal2settings.mat', 'Save MicrophoneCal2 settings file...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('saving cancelled...');
		return;
    end
	% save cal data
    disp(['Saving settings to ' fname])
    cal = handles.h2.cal; 
	save(fullfile(fpath, fname), '-MAT', 'cal');
%--------------------------------------------------------------------------
function buttonLoadSettings_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uigetfile('*_MicCal2settings.mat', 'Load MicrophoneCal2 settings file...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('loading cancelled...');
		return;
    end
	% load cal data
	disp(['Loading settings from ' fname])
	load(fullfile(fpath, fname), 'cal');
	handles.h2.cal = cal;
	handles.h2.COMPLETE = 0; % calibration with these settings is incomplete
	guidata(hObject, handles);    
    MicrophoneCal2_updateUI;
%--------------------------------------------------------------------------
function buttonDefaultSettings_Callback(hObject, eventdata, handles)
	disp('loading default settings...');
    handles.h2.cal = handles.h2.defaults;
    handles.h2.COMPLETE = 0; % calibration with these settings is incomplete
    guidata(hObject, handles);
    MicrophoneCal2_updateUI
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for calibration settings   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editFmin_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0, handles.h2.cal.Fmax])	% check limits
		handles.h2.cal.Fmin = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Fmin);
    end
function editFmax_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [handles.h2.cal.Fmin, 20000])	% check limits
		handles.h2.cal.Fmax = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Fmax);
    end
function editFstep_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [1, handles.h2.cal.Fmax-handles.h2.cal.Fmin])	% check limits
		handles.h2.cal.Fstep = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Fstep);
    end
function editReps_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [1, 100])	% check limits
		handles.h2.cal.Reps = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.Reps);
    end
function editAtten_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0, 120])	% check limits
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
    handles.h2.cal.DAlevel = read_ui_str(hObject, 'n'); 
    guidata(hObject, handles);
function editRefMicSens_Callback(hObject, eventdata, handles)
    handles.h2.cal.RefMicSens = read_ui_str(hObject, 'n'); 
    guidata(hObject, handles);
function editRefGain_Callback(hObject, eventdata, handles)
    handles.h2.cal.RefGain_dB = read_ui_str(hObject, 'n'); 
    guidata(hObject, handles);
function editMicGain_Callback(hObject, eventdata, handles)
    handles.h2.cal.MicGain_dB = read_ui_str(hObject, 'n'); 
    guidata(hObject, handles);
function radioFieldType_SelectionChangeFcn(hObject, eventdata, handles)
     hSelected = hObject; % for R2007a
     % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
     tag = get(hSelected, 'Tag');
     switch tag
         case 'radioPressure'
             disp('pressure field selected')
             handles.h2.FieldType = 'PRESSURE'; 
             guidata(hObject, handles);
         case 'radioFree'
             disp('free field selected')
             handles.h2.FieldType = 'FREE'; 
             guidata(hObject, handles);
     end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for TDT settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editStimOutChan_Callback(hObject, eventdata, handles)
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.OutChannel = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
function editRefInChan_Callback(hObject, eventdata, handles)
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
	handles.h2.cal.RefChannel = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
function editMicInChan_Callback(hObject, eventdata, handles)
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
	handles.h2.cal.MicChannel = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for results --- editing these boxes has no effects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editFreqVal_Callback(hObject, eventdata, handles)
function editRefVal_Callback(hObject, eventdata, handles)
function editRefSPL_Callback(hObject, eventdata, handles)
function editMicVal_Callback(hObject, eventdata, handles)
function editMicSPL_Callback(hObject, eventdata, handles)
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
function editStimOutChan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRefInChan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editMicInChan_CreateFcn(hObject, eventdata, handles)
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

