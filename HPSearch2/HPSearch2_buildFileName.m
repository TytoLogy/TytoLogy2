function [curvefile, curvepath, curvefilename] = HPSearch2_buildFileName(animal, curvetype)
%------------------------------------------------------------------------
% HPSearch2_buildFileName.m
%------------------------------------------------------------------------
% 
% generates the output data filename
%
%------------------------------------------------------------------------
% Input Arguments:
% 
% 	animal              animal info structure
%	curvetype           curve type: ITD, BF, etc.
%
% Output arguments:
%	curvefile			full data file path and filename string
% 	curvepath			path to data file
% 	curvefilename		data file name
%
%------------------------------------------------------------------------
%  Go Ashida & Sharad J. Shanbhag
%   ashida@umd.edu
%   sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (HPCurve_buildOutputdataFileName) : 2 March, 2010 (SJS)
% Upgraded Version Written (HPSearch2_buildFileName) : 9 March, 2012 (GA)
%
% Revisions: 
% 
%------------------------------------------------------------------------

exptime = now; 
animstr = zeropadding(animal.Animal);
unitstr = zeropadding(animal.Unit);
recnstr = zeropadding(animal.Rec); 

% build proposed file name
curvefilename = [ animstr '.' unitstr '.' recnstr '.' ...
                  datestr(now,'HHMM') '.' curvetype '.dat' ]; 

% get a data file name
[curvefilename, curvepath] = uiputfile('*.dat', 'Save experiment curve data in file', curvefilename);

if curvefilename == 0
    curvefile = 0;
	curvepath = 0;
    return;
end

% create the .dat file name for writing the binary data to disk
curvefile = fullfile(curvepath, curvefilename);


%----- function to return zero-padded string
function outstr = zeropadding(instr)
    tmp = str2double(instr); 
    if ( ~ischar(instr) || isnan(tmp) ) % if not numeric then do nothing
        outstr = instr; 
        return;
    end
    % check length
    len = length(instr);
    if len==0;
        pad = '000';
    elseif len==1; 
        pad = '00';
    elseif len==2; 
        pad = '0';
    else
        pad = '';
    end
    outstr = [ pad instr ];
