% HPSearch2c_storecurveparams.m
%------------------------------------------------------------------------
% 
% Script to copy current parameter struct to each curve type parameter struct
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch2_storecurveparams) Oct 2011 by GA
% Adopted for HPSearch2a (HPSearch2a_storecurveparams): Aug 2012 by GA 
% Adopted for HPSearch2b (HPSearch2b_storecurveparams): Nov 2012 by GA 
% Adopted for HPSearch2c (HPSearch2c_storecurveparams): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

str = upper(handles.h2.paramCurrent.curvetype); 

switch str
    case 'BF'
        handles.h2.paramBF = handles.h2.paramCurrent;
    case 'ITD'
        handles.h2.paramITD = handles.h2.paramCurrent;
    case 'ILD'
        handles.h2.paramILD = handles.h2.paramCurrent;
    case 'ABI'
        handles.h2.paramABI = handles.h2.paramCurrent;
    case 'BC'
        handles.h2.paramBC = handles.h2.paramCurrent;
    case 'FILDL'
        handles.h2.paramFILDL = handles.h2.paramCurrent;
    case 'FILDR'
        handles.h2.paramFILDR = handles.h2.paramCurrent;
    case 'BEAT'
        handles.h2.paramBeat = handles.h2.paramCurrent;
    case 'SAMP'
        handles.h2.paramsAMp = handles.h2.paramCurrent;
    case 'SAMF'
        handles.h2.paramsAMf = handles.h2.paramCurrent;
    case 'CF'
        handles.h2.paramCF = handles.h2.paramCurrent;
    case 'CD'
        handles.h2.paramCD = handles.h2.paramCurrent;
    case 'PH'
        handles.h2.paramPH = handles.h2.paramCurrent;
end
