function HPSearch2_enableUIs(handles,str)
%------------------------------------------------------------------------
% HPSearch2_enableUIs.m
%------------------------------------------------------------------------
% This function enables/disables:  
%  TDTenable, Curve, Click buttons
%  setting fields, plot radiobuttons
%------------------------------------------------------------------------
% Note: This function does NOT affect the Search and Abort buttons
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 13 March, 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

str = upper(str);

switch str

% enabling buttons and editboxes
    case 'ENABLE'
        enable_ui(handles.buttonTDTenable);
        enable_ui(handles.buttonCurve);
        enable_ui(handles.buttonClick);

        enable_ui(handles.editDate);
        enable_ui(handles.editAnimal);
        enable_ui(handles.editUnit);
        enable_ui(handles.editRec);
        enable_ui(handles.editPen);
        enable_ui(handles.editAP);
        enable_ui(handles.editML);
        enable_ui(handles.editDepth);

        enable_ui(handles.editISI);
        enable_ui(handles.editDuration);
        enable_ui(handles.editDelay);
        enable_ui(handles.editRamp);
        enable_ui(handles.checkRadVary);
        enable_ui(handles.checkFrozenStim);

        enable_ui(handles.editInput);
        enable_ui(handles.editOutputL);
        enable_ui(handles.editOutputR);

        enable_ui(handles.editAcqDuration);
        enable_ui(handles.editSweepPeriod);
        enable_ui(handles.editTTLPulseDur);

        enable_ui(handles.editCircuitGain);
        enable_ui(handles.editHPFreq);
        enable_ui(handles.editLPFreq);

        enable_ui(handles.editWindowWidth);
        enable_ui(handles.editStartTime);
        enable_ui(handles.editEndTime);
        enable_ui(handles.editThres);
        enable_ui(handles.editRaster);

        enable_ui(handles.radioShowAll);
        enable_ui(handles.radioShowNone);
        enable_ui(handles.radioShowResp);
        enable_ui(handles.radioShowRU);

        return;

    case 'DISABLE'
        disable_ui(handles.buttonTDTenable);
        disable_ui(handles.buttonCurve);
        disable_ui(handles.buttonClick);

        disable_ui(handles.editDate);
        disable_ui(handles.editAnimal);
        disable_ui(handles.editUnit);
        disable_ui(handles.editRec);
        disable_ui(handles.editPen);
        disable_ui(handles.editAP);
        disable_ui(handles.editML);
        disable_ui(handles.editDepth);

        disable_ui(handles.editISI);
        disable_ui(handles.editDuration);
        disable_ui(handles.editDelay);
        disable_ui(handles.editRamp);
        disable_ui(handles.checkRadVary);
        disable_ui(handles.checkFrozenStim);

        disable_ui(handles.editInput);
        disable_ui(handles.editOutputL);
        disable_ui(handles.editOutputR);

        disable_ui(handles.editAcqDuration);
        disable_ui(handles.editSweepPeriod);
        disable_ui(handles.editTTLPulseDur);

        disable_ui(handles.editCircuitGain);
        disable_ui(handles.editHPFreq);
        disable_ui(handles.editLPFreq);

        disable_ui(handles.editWindowWidth);
        disable_ui(handles.editStartTime);
        disable_ui(handles.editEndTime);
        disable_ui(handles.editThres);
        disable_ui(handles.editRaster);

        disable_ui(handles.radioShowAll);
        disable_ui(handles.radioShowNone);
        disable_ui(handles.radioShowResp);
        disable_ui(handles.radioShowRU);

        return;


end

