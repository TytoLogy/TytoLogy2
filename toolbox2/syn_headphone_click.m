function S = syn_headphone_click(duration, delay, Fs, samples, itd, varargin)
%function S = syn_headphone_click(duration, delay, Fs, samples, itd, varargin)
%---------------------------------------------------------------------
%	Synthesize "click" for headphone output
%---------------------------------------------------------------------
%	Input Arguments:
%		duration		time of total stimulus in ms
%       delay           delay in ms
%		Fs				output sampling rate
%		samples			click samples (should be a positive even integer)
%		itd         	itd in us (+ = right ear leads, - = left ear leads)
%		varargin{1}		stim type (cond or rare)
%
%	Output Arguments:
%		S		L & R click deta 
%---------------------------------------------------------------------
%	See Also:	syn_headphone_tone, syn_headphone_noise
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%   Go Ashida
%	ashida@umd.edu
%---------------------------------------------------------------------
% Created: 18 March, 2012
%
%------------------------------------------------------------------------

if nargin < 5
	error([mfilename ': incorrect number of input arguments']);
elseif nargin == 5
    clicktype = 'COND';
else
    clicktype = varargin{1};
end

switch upper(clicktype)
    case 'COND'
        c1 = 1;
        c2 = -1;
    case 'RARE'
        c1 = -1;
        c2 = 1;
    otherwise
    	error([mfilename ': bad click type']);
end

% time length of each param (bins)
tlen = ms2bin(duration, Fs); 
delaysamples = ms2bin(delay, Fs);
itdsamples = ms2bin(itd/1000, Fs);

% make zero vector 
S = zeros(2, tlen);

% generate click
tL1 = delaysamples + 1;
tL2 = delaysamples + round(samples/2);
tL3 = delaysamples + samples;
tR1 = delaysamples + 1 - itdsamples;
tR2 = delaysamples + round(samples/2) - itdsamples;
tR3 = delaysamples + samples - itdsamples;

S(1,(tL1:tL2)) = c1;
S(2,(tR1:tR2)) = c1;

S(1,(tL2+1:tL3)) = c2;
S(2,(tR2+1:tR3)) = c2;

