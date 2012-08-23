% MicrophoneCal2_updateUI.m
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Originally Written (MicrophoneCal): 2008-2010 by SJS
% Renamed Version Created (MicrophoneCal2_updateUI): November, 2011 by GA
%
% Revisions: modified version for MicrophoneCal2
% 
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the UI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_ui_str(handles.editFmin, handles.h2.cal.Fmin);
update_ui_str(handles.editFmax, handles.h2.cal.Fmax);
update_ui_str(handles.editFstep, handles.h2.cal.Fstep);
update_ui_str(handles.editReps, handles.h2.cal.Reps);
update_ui_str(handles.editAtten, handles.h2.cal.Atten);

update_ui_str(handles.editDAlevel, handles.h2.cal.DAlevel);
update_ui_str(handles.editRefMicSens, handles.h2.cal.RefMicSens);
update_ui_str(handles.editRefGain, handles.h2.cal.RefGain_dB);
update_ui_str(handles.editMicGain, handles.h2.cal.MicGain_dB);

str = upper(handles.h2.cal.FieldType);
switch str
    case 'PRESSURE'
    set(handles.radioFieldType, 'SelectedObject', handles.radioPressure);
    case 'FREE'
    set(handles.radioFieldType, 'SelectedObject', handles.radioFree);
end    
    
update_ui_str(handles.editStimOutChan, handles.h2.cal.OutChannel);
update_ui_str(handles.editRefInChan, handles.h2.cal.RefChannel);
update_ui_str(handles.editMicInChan, handles.h2.cal.MicChannel);

