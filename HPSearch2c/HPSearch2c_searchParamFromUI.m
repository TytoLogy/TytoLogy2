function out = HPSearch2c_searchParamFromUI(handles)
%------------------------------------------------------------------------
% out = HPSearch2c_searchParamFromUI(handles)
%------------------------------------------------------------------------
%
% updates search parameter values from user interface controls
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written (stimUpdateFromUI): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_searchParamFromUI): 2011-2012 by GA
% Adopted for HPSearch2a (HPSearch2a_searchParamFromUI): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_searchParamFromUI): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_searchParamFromUI): Jan 2015 by GA 
%  --- AM tone has been added
%------------------------------------------------------------------------

out.LeftON = read_ui_val(handles.checkLeftON);
out.RightON = read_ui_val(handles.checkRightON);

out.ITD = read_ui_val(handles.sliderITD);
out.ILD = read_ui_val(handles.sliderILD);
out.Latt = read_ui_val(handles.sliderLatt);
out.Ratt = read_ui_val(handles.sliderRatt);
out.ABI = read_ui_val(handles.sliderABI);
out.BC = read_ui_val(handles.sliderBC);
out.Freq = read_ui_val(handles.sliderFreq);
out.BW = read_ui_val(handles.sliderBW);
out.Fmax = min( round(out.Freq + out.BW/2), handles.h2.search.limits.Freq(2) );
out.Fmin = max( round(out.Freq - out.BW/2), handles.h2.search.limits.Freq(1) );
out.sAMp = read_ui_val(handles.slidersAMp);
out.sAMf = read_ui_val(handles.slidersAMf);

tag = get( get(handles.radioSearchStim, 'SelectedObject'), 'Tag' );
switch tag
    case 'radioSearchStimNoise'
        out.stimtype = 'NOISE'; 
    case 'radioSearchStimTone'
        out.stimtype = 'TONE'; 
    case 'radioSearchStimAMnoise'
        out.stimtype = 'AMNOISE'; 
        if ~(out.Fmin<out.Fmax)
            out.Fmax = out.Fmin+1;
        end
    case 'radioSearchStimAMtone'
        out.stimtype = 'AMTONE'; 
end
