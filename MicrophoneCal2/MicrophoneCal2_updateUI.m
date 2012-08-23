% MicrophoneCal2_updateUI.m
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (MicrophoneCal): 2008-2010 by SJS
% Upgraded Version Written (MicrophoneCal2_updateUI): 2011-2012 by GA
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the UI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calibration settings
update_ui_str(handles.editFmin, handles.h2.cal.Fmin);
update_ui_str(handles.editFmax, handles.h2.cal.Fmax);
update_ui_str(handles.editFstep, handles.h2.cal.Fstep);
update_ui_str(handles.editReps, handles.h2.cal.Reps);
update_ui_str(handles.editAtten, handles.h2.cal.Atten);

% microphone settings
update_ui_str(handles.editDAlevel, handles.h2.cal.DAlevel);
update_ui_str(handles.editRefMicSens, handles.h2.cal.RefMicSens);
update_ui_str(handles.editRefGain, handles.h2.cal.RefGain_dB);
update_ui_str(handles.editMicGain, handles.h2.cal.MicGain_dB);

% field type
str = upper(handles.h2.cal.FieldType);
switch str
    case 'PRESSURE'
    set(handles.radioFieldType, 'SelectedObject', handles.radioPressure);
    case 'FREE'
    set(handles.radioFieldType, 'SelectedObject', handles.radioFree);
end    

% stimulus settings
update_ui_str(handles.editISI, handles.h2.cal.ISI);
update_ui_str(handles.editDuration, handles.h2.cal.Duration);
update_ui_str(handles.editDelay, handles.h2.cal.Delay);
update_ui_str(handles.editRamp, handles.h2.cal.Ramp);

% TDT settings
update_ui_str(handles.editAcqDuration, handles.h2.cal.AcqDuration);
update_ui_str(handles.editSweepPeriod, handles.h2.cal.SweepPeriod);
update_ui_str(handles.editTTLPulseDur, handles.h2.cal.TTLPulseDur);
update_ui_str(handles.editHPFreq, handles.h2.cal.HPFreq);
update_ui_str(handles.editLPFreq, handles.h2.cal.LPFreq);

% channel settings
update_ui_str(handles.editOutChannel, handles.h2.config.OutChannel);
update_ui_str(handles.editRefChannel, handles.h2.config.RefChannel);
update_ui_str(handles.editMicChannel, handles.h2.config.MicChannel);

% save raw data checkbox
if handles.h2.cal.SaveRawData
    update_ui_val(handles.checkSaveRawData, 1);
else
    update_ui_val(handles.checkSaveRawData, 0);
end
