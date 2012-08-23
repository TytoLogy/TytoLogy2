function outdata = HPSearch2_loadcal(filename, sidestr)
%--------------------------------------------------------------------------
%outdata = HPSearch2_loadcal(filename, sidestr)
%--------------------------------------------------------------------------
%
%	Function to read in calibration data generated by the HeadphoneCal2 program.
%
%--------------------------------------------------------------------------
%	Input Arguments:
%		filename	name of cal file (usually ear.cal)
%       sidestr	    'L' or 'R' 
%--------------------------------------------------------------------------
%	Output Arguments:
%		outdata		Matlab structure containing cal data
%--------------------------------------------------------------------------
%	Critical elements are: 
%		caldata.mag	  : [2xN] array
%		caldata.phase : [2xN] array
%		caldata.Freqs : [1xN] array
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida 
% sshanbha@aecom.yu.edu 
% ashida@umd.edu 
%------------------------------------------------------------------------
% Originally Written (load_headphone_cal): 2009-2011 by SJS
% Renamed Version Created (HPSearch2_loadcal): 09 November, 2011 by GA
%
% Revisions: modified version for HPSearch2
% 
%------------------------------------------------------------------------

if ~exist(filename)
	error(['Calibration file ' filename ' not found']);
end

load(filename, 'caldata')

switch caldata.Side
    case 'LEFT'  % only LEFT cal data is available 
        SIDE = 1;
    case 'RIGHT' % only RIGHT cal data is available
        SIDE = 2;
    case 'BOTH' 
        switch sidestr
            case 'L'
                SIDE = 1;
            case 'R'
                SIDE = 2;
            otherwise  % assume LEFT (channel 1)
                SIDE = 1;
        end 
end

outdata.Freqs = caldata.Freqs;
outdata.mag = caldata.mag(SIDE, :);
outdata.phase = caldata.phase(SIDE, :);

% preconvert phases from angle (RADIANS) to microsecond
outdata.phase_us = ( 1.0e6 * unwrap(outdata.phase) ) ./ (2 * pi * outdata.Freqs);
outdata.phase_us( (outdata.Freqs==0) ) = 0; % if freq=0, then phase_us=0

% get the overall min and max dB SPL levels
outdata.mindbspl = min(outdata.mag);
outdata.maxdbspl = max(outdata.mag);

% precompute the inverse filter, and convert to RMS value.
%outdata.maginv = zeros(size(outdata.mag));
% subtract SPL mags (at each freq) from the min dB recorded 
% for each channel and convert back to Pa (rms)
outdata.maginv = invdb(outdata.mindbspl - outdata.mag);

outdata.DAlevel = 5;  % default DAlevel
if isfield(caldata, 'cal')
	if isfield(caldata.cal, 'DAlevel')
		outdata.DAlevel = caldata.cal.DAlevel;
	end
end

