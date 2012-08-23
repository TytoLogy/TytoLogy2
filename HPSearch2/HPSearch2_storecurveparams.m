% HPSearch2_storecurveparams.m
%------------------------------------------------------------------------
% 
% Script to copy current parameter struct to each curve type parameter struct
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 28 October, 2011 by GA
%
% Revisions: 
% 
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
