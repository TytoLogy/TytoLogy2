% HeadphoneCal2_updateUI.m
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Originally Written (HeadphoneCal): 2009-2011 by SJS
% Renamed Version Created (HeadphoneCal2_updateUI): November, 2011 by GA
%
% Revisions: modified version for HeadphoneCal2
% 
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the UI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_ui_str(handles.editFmin, handles.h2.cal.Fmin);
update_ui_str(handles.editFmax, handles.h2.cal.Fmax);
update_ui_str(handles.editFstep, handles.h2.cal.Fstep);
update_ui_str(handles.editReps, handles.h2.cal.Reps);
%update_ui_val(handles.checkAutoSave, handles.h2.cal.AutoSave);

str = upper(handles.h2.cal.Side);
switch str
    case 'BOTH'
    set(handles.radioSide, 'SelectedObject', handles.radioBoth);
    case 'LEFT'
    set(handles.radioSide, 'SelectedObject', handles.radioLeft);
    case 'RIGHT'
    set(handles.radioSide, 'SelectedObject', handles.radioRight);
end

str = upper(handles.h2.cal.AttenType);
switch str
    case 'VARIED'
    set(handles.radioAtten, 'SelectedObject', handles.radioAttenVaried);
    enable_ui(handles.editMinLevel);
    enable_ui(handles.editMaxLevel);
    enable_ui(handles.editAttenStep);
    disable_ui(handles.editAttenFixed);             
    case 'FIXED'
    set(handles.radioAtten, 'SelectedObject', handles.radioAttenFixed);
    disable_ui(handles.editMinLevel);
    disable_ui(handles.editMaxLevel);
    disable_ui(handles.editAttenStep);
    enable_ui(handles.editAttenFixed);             
end

update_ui_str(handles.editMinLevel, handles.h2.cal.MinLevel);
update_ui_str(handles.editMaxLevel, handles.h2.cal.MaxLevel);
update_ui_str(handles.editAttenStep, handles.h2.cal.AttenStep);
update_ui_str(handles.editAttenFixed, handles.h2.cal.AttenFixed);

update_ui_str(handles.editGainL, handles.h2.cal.MicGainL_dB);
update_ui_str(handles.editGainR, handles.h2.cal.MicGainR_dB);

update_ui_str(handles.editOutChanL, handles.h2.cal.OutChanL);
update_ui_str(handles.editOutChanR, handles.h2.cal.OutChanR);
update_ui_str(handles.editInChanL, handles.h2.cal.InChanL);
update_ui_str(handles.editInChanR, handles.h2.cal.InChanR);
update_ui_str(handles.editISI, handles.h2.cal.ISI);

