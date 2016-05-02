function out = HPSearch2c_plotParamFromUI(handles)
%------------------------------------------------------------------------
% out = HPSearch2c_plotParamFromUI(handles)
%------------------------------------------------------------------------
%
% updates plot/threshold parameter values from user interface controls
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch2a_plotParamFromUI): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_plotParamFromUI): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_plotParamFromUI): Jan 2015 by GA
% (no major changes to the code have been made from 2b, only file names)
%------------------------------------------------------------------------

% plot checkboxes 
tmp = get( handles.checkAxesResp, 'Checked' );
if( strcmpi( tmp, 'On' )),
    out.plotResp = 1;
else
    out.plotResp = 0;
end

tmp = get( handles.checkAxesRaster, 'Checked' );
if( strcmpi( tmp, 'On' )),
    out.plotRaster = 1;
else
    out.plotRaster = 0;
end

tmp = get( handles.checkAxesCurve, 'Checked' );
if( strcmpi( tmp, 'On' )),
    out.plotCurve = 1;
else
    out.plotCurve = 0;
end

tmp = get( handles.checkAxesUpclose, 'Checked' );
if( strcmpi( tmp, 'On' )),
    out.plotUpclose = 1;
else
    out.plotUpclose = 0;
end

tmp = get( handles.checkAxesPSTH, 'Checked' );
if( strcmpi( tmp, 'On' )),
    out.plotPSTH = 1;
else
    out.plotPSTH = 0;
end

tmp = get( handles.checkAxesISIH, 'Checked' );
if( strcmpi( tmp, 'On' )),
    out.plotISIH = 1;
else
    out.plotISIH = 0;
end

% manual scales
out.Threshold = read_ui_val(handles.sliderManualTh);
out.Yaxis     = read_ui_val(handles.sliderManualY);

% auto threshold
out.ThresSD = read_ui_str(handles.editThres, 'n');

% threshold radiobutton
tag = get( get(handles.radioThreshold, 'SelectedObject'), 'Tag' );
switch tag
    case 'radioThAuto'
        out.ThAuto = 1; 
    case 'radioThManual'
        out.ThAuto = 0; 
end

% detection radiobutton
tag = get( get(handles.radioDetection, 'SelectedObject'), 'Tag' );
switch tag
    case 'radioPeakAuto'
        out.Peak = 0; 
    case 'radioPeakTop'
        out.Peak = 1; 
    case 'radioPeakBottom'
        out.Peak = -1; 
end

% scale radiobutton
tag = get( get(handles.radioScale, 'SelectedObject'), 'Tag' );
switch tag
    case 'radioScale0'
        out.Scale = 1.0; % =1.0[V]
    case 'radioScale1'
        out.Scale = 1.0e-1; 
    case 'radioScale2'
        out.Scale = 1.0e-2; 
    case 'radioScale3'
        out.Scale = 1.0e-3; % =1.0[mV]
    case 'radioScale4'
        out.Scale = 1.0e-4; 
    case 'radioScale5'
        out.Scale = 1.0e-5; 
end

% sign radiobutton
tag = get( get(handles.radioSign, 'SelectedObject'), 'Tag' );
switch tag
    case 'radioThPlus'
        out.Sign = 1.0; 
    case 'radioThMinus'
        out.Sign = -1.0; 
end

% Y-axis radiobutton
tag = get( get(handles.radioYaxis, 'SelectedObject'), 'Tag' );
switch tag
    case 'radioYAuto'
        out.YAuto = 1; 
    case 'radioYManual'
        out.YAuto = 0; 
end

