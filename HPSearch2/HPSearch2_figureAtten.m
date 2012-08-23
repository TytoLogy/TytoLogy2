function atten_val = HPSearch2_figureAtten(spl_val, rms_val, mindbspl, channelON)
%---------------------------------------------------------------------
%[atten_val, spl_val] = HPSearch2_figureAtten(spl_val, rms_val, mindbspl, channelON)
%---------------------------------------------------------------------
%	Calibration Toolbox 
%---------------------------------------------------------------------
% 
%	Given rms_value of sound and calibration data (caldata), computes the 
% 	atten_val required to obtain desired spl_val output levels.
% 	
% 	Same as figure_atten, but performs more checks on input and output levels
% 	
%---------------------------------------------------------------------
%	Input Arguments:
%		spl_val		desired output SPL value (dB)
% 		rms_val     rms values (from syn*.m functions)
% 		mindbspl    mindbspl of caldata structure
%       channelON   on=1, off=0
%  											
%	Output Arguments:
%		atten_val	attenuation setting
% 
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Sharad Shanbhag & Go Ashida
%	sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version Written (figure_headphone_atten): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_figureAtten): 2011-2012 by GA
%
% Revisions: 
%------------------------------------------------------------------------

MAXATTEN = 120;
MINATTEN = 0;

if channelON
    atten_val = mindbspl + db(rms_val) - spl_val;
else
    atten_val = MAXATTEN;
    return; 
end

if ( atten_val > MAXATTEN ) && ( spl_val ~= 0 )
	disp([mfilename ' warning: requested SPL too low']);
	atten_val = MAXATTEN;
elseif atten_val < MINATTEN
	disp([mfilename ' warning: requested SPL too high']);
	atten_val = MINATTEN;
elseif isnan(atten_val)
	disp([mfilename ' warning: NaN returned for SPL']);
	disp(sprintf('RMS = %.4f, SPL = %.4f', rms_val, spl_val));
	atten_val = MAXATTEN;
end

