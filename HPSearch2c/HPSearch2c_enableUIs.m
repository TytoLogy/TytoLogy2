function HPSearch2c_enableUIs(handles,str)
%------------------------------------------------------------------------
% HPSearch2c_enableUIs.m
%------------------------------------------------------------------------
% This function enables/disables:  
%  TDTenable, Curve, Click buttons
%  setting fields, plot radiobuttons
%------------------------------------------------------------------------
% Note: This function does NOT affect the Search and Abort buttons
%------------------------------------------------------------------------
%  Go Ashida 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch_enableUIs): Mar 2012 by GA
% Adopted for HPSearch2a (HPSearch2a_enableUIs): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_enableUIs): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_init): Jan 2015 by GA 
%  - added code for external stimulus 
%------------------------------------------------------------------------

str = upper(str);

switch str

% enabling buttons and editboxes
    case 'ENABLE'
        enable_ui(handles.buttonSearch);
        enable_ui(handles.buttonTDTenable);
        enable_ui(handles.buttonCurve);
        enable_ui(handles.buttonClick);
        enable_ui(handles.buttonExtStimLoad);
        enable_ui(handles.buttonExtStimRun);
        
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

        enable_ui(handles.editHPFreq);
        enable_ui(handles.editLPFreq);
        enable_ui(handles.checkHighPass);
        enable_ui(handles.checkLowPass);

        enable_ui(handles.editWindowWidth);
        enable_ui(handles.editStartTime);
        enable_ui(handles.editEndTime);
        enable_ui(handles.editRaster);

        % pause and abort will be disabled after all UI elements are enabled
        disable_ui(handles.buttonPause);
        disable_ui(handles.buttonAbort);
        return;

    case 'DISABLE'
        disable_ui(handles.buttonTDTenable);
        disable_ui(handles.buttonCurve);
        disable_ui(handles.buttonClick);
        disable_ui(handles.buttonExtStimLoad);
        disable_ui(handles.buttonExtStimRun);

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

        disable_ui(handles.editHPFreq);
        disable_ui(handles.editLPFreq);
        disable_ui(handles.checkHighPass);
        disable_ui(handles.checkLowPass);

        disable_ui(handles.editWindowWidth);
        disable_ui(handles.editStartTime);
        disable_ui(handles.editEndTime);
        disable_ui(handles.editRaster);

        % pause and abort will be enabled after all UI elements got disabled
        enable_ui(handles.buttonPause);
        enable_ui(handles.buttonAbort);
        return;

end

