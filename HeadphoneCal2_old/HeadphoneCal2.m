function varargout = HeadphoneCal2(varargin)
%HEADPHONECAL2 M-file for HeadphoneCal2.fig
%   HEADPHONECAL2, by itself, creates a new HEADPHONECAL2 or raises the existing singleton*.
%
%   H = HEADPHONECAL2 returns the handle to a new HEADPHONECAL2 or the handle to
%      the existing singleton*.
%

%  HeadphoneCal was originally written by Sharad J Shanbhag in 2009-2011. 
%  Based on MicrophoneCal, this modified version named HeadphoneCal2 
%  was written by Go Ashida in Nov 2011.

% Last Modified by GUIDE v2.5 14-Mar-2012 01:37:02

%--------------------------------------------------------------------------
% ** Important Notes ** (Nov 2011, GA)
%   Parameters used in HeadphoneCal2 are stored under the handles.h2 structure,
%   while parameters used in HeadphoneCal are stored directly under handles. 
%
%
%

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
    handles.h2 = struct();
    % setting defaults
    handles.h2.DefaultType = HeadphoneCal2_init('INIT');
    handles.h2.defaults = HeadphoneCal2_init(handles.h2.DefaultType);
    % setting current cal 
    handles.h2.cal = handles.h2.defaults;
    % current fr settings is empty
    handles.h2.fr.loadedL = 0;
    handles.h2.fr.loadedR = 0;
    % calibration is incomplete
    handles.h2.COMPLETE = 0;
    % resetting ABORT flag
    handles.h2.ABORT = 0;
    % Choose default command line output for HeadphoneCal2
    handles.output = hObject;
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
    % updating buttons and resetting COMPLETE flag
    disable_ui(handles.buttonCalibrate);
    enable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0);
    handles.h2.COMPLETE = 0;
    COMPLETE = 0;
    guidata(hObject, handles);
	
    HeadphoneCal2_Run;
    %pause(2); COMPLETE = 1;  % for testing/debugging

    % updating buttons 
    enable_ui(handles.buttonCalibrate);
    disable_ui(handles.buttonAbort);
    update_ui_val(handles.buttonAbort, 0);
    if COMPLETE
    	handles.h2.COMPLETE = 1;
        enable_ui(handles.buttonSaveCal);
        HeadphoneCal2_plot(handles.h2.caldata);
    end
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function buttonAbort_Callback(hObject, eventdata, handles)
	disp('ABORTING Calibration!')
	handles.h2.ABORT = 1;
	guidata(hObject, handles);	
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveSettings_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uiputfile('*_HPCal2settings.mat', 'Save HeadphoneCal2 settings file...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('saving cancelled...');
		return;
    end
	% save cal data
    disp(['Saving settings to ' fname])
    cal = handles.h2.cal; 
	save(fullfile(fpath, fname), '-MAT', 'cal');
function buttonLoadSettings_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uigetfile('*_HPCal2settings.mat', 'Load HeadphoneCal2 settings file...');
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
    HeadphoneCal2_updateUI;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save/Load button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveCal_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uiputfile('*_cal2.mat', 'Save HeadphoneCal2 calibration data file...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('saving cancelled...');
		return;
    end
	% save cal data
    disp(['Saving microphone calibration data to ' fname])
    caldata = handles.h2.caldata; 
	save(fullfile(fpath, fname), 'caldata', '-mat');
%--------------------------------------------------------------------------
function buttonLoadFRL_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uigetfile('*_fr2.mat', 'Load FR data for LEFT microphone...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('loading cancelled...');
		return;
    end
	% save cal data
    disp(['Loading microphone calibration data from ' fname])
    handles.h2.fr.frfileL = fullfile(fpath, fname);
	load(handles.h2.fr.frfileL, 'frdata');
    handles.h2.fr.frdataL = frdata;
    handles.h2.fr.loadedL = 1;
    guidata(hObject, handles);
	update_ui_str(handles.textFRL, handles.h2.fr.frfileL);
%--------------------------------------------------------------------------
function buttonLoadFRR_Callback(hObject, eventdata, handles)
	[fname, fpath] = ...
        uigetfile('*_fr2.mat', 'Load FR data for RIGHT microphone...');
	% return if user hits CANCEL button (settingsfile == 0)
	if fname == 0
		disp('loading cancelled...');
		return;
    end
	% save cal data
    disp(['Loading microphone calibration data from ' fname])
    handles.h2.fr.frfileR = fullfile(fpath, fname);
	load(handles.h2.fr.frfileR, 'frdata');
    handles.h2.fr.frdataR = frdata;
    handles.h2.fr.loadedR = 1;
    guidata(hObject, handles);
	update_ui_str(handles.textFRR, handles.h2.fr.frfileR);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes/radiobuttons/checkbox for calibration settings   
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
function radioSide_SelectionChangeFcn(hObject, eventdata, handles)
     hSelected = hObject; % for R2007a
     % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
     tag = get(hSelected, 'Tag');
     switch tag
         case 'radioBoth'
             disp('both selected')
             handles.h2.cal.Side = 'BOTH'; 
             guidata(hObject, handles);
         case 'radioLeft'
             disp('left selected')
             handles.h2.cal.Side = 'LEFT'; 
             guidata(hObject, handles);
         case 'radioRight'
             disp('right selected')
             handles.h2.cal.Side = 'RIGHT'; 
             guidata(hObject, handles);
     end
% function checkAutoSave_Callback(hObject, eventdata, handles)
%       handles.h2.cal.AutoSave = read_ui_val(hObject);
%       guidata(hObject, handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes/radiobuttons for attenuation settings   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editMinLevel_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0, handles.h2.cal.MaxLevel])	% check limits
		handles.h2.cal.MinLevel = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MinLevel);
    end
function editMaxLevel_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [handles.h2.cal.MinLevel 100])	% check limits
		handles.h2.cal.MaxLevel = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MaxLevel);
    end
function editAttenStep_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [1 handles.h2.cal.MaxLevel-handles.h2.cal.MinLevel])	% check limits
		handles.h2.cal.AttenStep = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.AttenStep);
    end
function editAttenFixed_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 120])	% check limits
		handles.h2.cal.AttenFixed = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.AttenFixed);
    end
function radioAtten_SelectionChangeFcn(hObject, eventdata, handles)
     hSelected = hObject; % for R2007a
     % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
     tag = get(hSelected, 'Tag');
     switch tag
         case 'radioAttenVaried'
             disp('fixed dB SPL selected')
             handles.h2.cal.AttenType = 'VARIED'; 
             guidata(hObject, handles);
             enable_ui(handles.editMinLevel);
             enable_ui(handles.editMaxLevel);
             enable_ui(handles.editAttenStep);
             disable_ui(handles.editAttenFixed);             
         case 'radioAttenFixed'
             disp('fixed attenuation selected')
             handles.h2.cal.AttenType = 'FIXED'; 
             guidata(hObject, handles);
             disable_ui(handles.editMinLevel);
             disable_ui(handles.editMaxLevel);
             disable_ui(handles.editAttenStep);
             enable_ui(handles.editAttenFixed);             
     end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for Microphone settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editGainL_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 120])	% check limits
		handles.h2.cal.MicGainL_dB = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MicGainL_dB);
    end
function editGainR_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 120])	% check limits
		handles.h2.cal.MicGainR_dB = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.MicGainR_dB);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for TDT settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editOutChanL_Callback(hObject, eventdata, handles)
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.OutChanL = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
function editOutChanR_Callback(hObject, eventdata, handles)
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.OutChanR = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
function editInChanL_Callback(hObject, eventdata, handles)
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.InChanL = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
function editInChanR_Callback(hObject, eventdata, handles)
	tmp = round(read_ui_str(hObject, 'n')); % round to integer
    handles.h2.cal.InChanR = tmp;
    update_ui_str(hObject, tmp);
    guidata(hObject, handles);
function editISI_Callback(hObject, eventdata, handles)
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, [0 1000])	% check limits
		handles.h2.cal.ISI = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.cal.ISI);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for results --- editing these boxes has no effects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editFreqVal_Callback(hObject, eventdata, handles)
function editRepVal_Callback(hObject, eventdata, handles)
function editAttenL_Callback(hObject, eventdata, handles)
function editValL_Callback(hObject, eventdata, handles)
function editSPLL_Callback(hObject, eventdata, handles)
function editAttenR_Callback(hObject, eventdata, handles)
function editValR_Callback(hObject, eventdata, handles)
function editSPLR_Callback(hObject, eventdata, handles)
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
function editISI_CreateFcn(hObject, eventdata, handles)
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





