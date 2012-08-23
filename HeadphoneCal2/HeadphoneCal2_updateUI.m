% HeadphoneCal2_updateUI.m
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (HeadphoneCal): 2008-2010 by SJS
% Upgraded Version Written (HeadphoneCal2_updateUI): 2011-2012 by GA
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the UI values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% microphone settings
update_ui_str(handles.editGainL, handles.h2.cal.MicGainL_dB);
update_ui_str(handles.editGainR, handles.h2.cal.MicGainR_dB);

% calibration settings
update_ui_str(handles.editFmin, handles.h2.cal.Fmin);
update_ui_str(handles.editFmax, handles.h2.cal.Fmax);
update_ui_str(handles.editFstep, handles.h2.cal.Fstep);
update_ui_str(handles.editReps, handles.h2.cal.Reps);
% calibration side radio button
str = upper(handles.h2.cal.Side);
switch str
    case 'BOTH'
    set(handles.radioSide, 'SelectedObject', handles.radioBoth);
    case 'LEFT'
    set(handles.radioSide, 'SelectedObject', handles.radioLeft);
    case 'RIGHT'
    set(handles.radioSide, 'SelectedObject', handles.radioRight);
end

% attenuation settings
update_ui_str(handles.editMinLevel, handles.h2.cal.MinLevel);
update_ui_str(handles.editMaxLevel, handles.h2.cal.MaxLevel);
update_ui_str(handles.editAttenStep, handles.h2.cal.AttenStep);
update_ui_str(handles.editAttenFixed, handles.h2.cal.AttenFixed);
% attenuation type radio button
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

% stimulus settings
update_ui_str(handles.editISI, handles.h2.cal.ISI);
update_ui_str(handles.editDuration, handles.h2.cal.Duration);
update_ui_str(handles.editDelay, handles.h2.cal.Delay);
update_ui_str(handles.editRamp, handles.h2.cal.Ramp);
update_ui_str(handles.editDAlevel, handles.h2.cal.DAlevel);

% TDT settings
update_ui_str(handles.editAcqDuration, handles.h2.cal.AcqDuration);
update_ui_str(handles.editSweepPeriod, handles.h2.cal.SweepPeriod);
update_ui_str(handles.editTTLPulseDur, handles.h2.cal.TTLPulseDur);
update_ui_str(handles.editHPFreq, handles.h2.cal.HPFreq);
update_ui_str(handles.editLPFreq, handles.h2.cal.LPFreq);

% channel settings
update_ui_str(handles.editOutChanL, handles.h2.config.OutChanL);
update_ui_str(handles.editOutChanR, handles.h2.config.OutChanR);
update_ui_str(handles.editInChanL, handles.h2.config.InChanL);
update_ui_str(handles.editInChanR, handles.h2.config.InChanR);

% save raw data checkbox
if handles.h2.cal.SaveRawData
    update_ui_val(handles.checkSaveRawData, 1);
else
    update_ui_val(handles.checkSaveRawData, 0);
end
