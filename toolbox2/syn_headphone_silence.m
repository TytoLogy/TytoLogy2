function [S, Smag, Sphi]  = syn_headphone_silence(duration, Fs, varargin)
%function [S, Smag, Sphi]  = syn_headphone_silence(duration, Fs, varargin)
%---------------------------------------------------------------------
%	Synthesize "silence" for headphone output
%---------------------------------------------------------------------
%	Input Arguments:
%		duration		time of stimulus in ms
%		Fs				output sampling rate
%		varargin		not used
%		
%	Output Arguments:
%		S		L & R silence deta 
%		Smag	L & R calibration magnitude (set to zero)
%		Sphi	L & R phase (set to zero)
%---------------------------------------------------------------------
%	See Also:	syn_headphone_tone, syn_headphone_noise
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%   Go Ashida
%	ashida@umd.edu
%---------------------------------------------------------------------
% Created: 14 March, 2012
%
%------------------------------------------------------------------------

if nargin < 2
	error([mfilename ': incorrect number of input arguments']);
end

% time length
tlen = ms2bin(duration, Fs); 

% return zero vector with the same length as tvec
S = zeros(2, tlen);
Smag = zeros(2, tlen);
Sphi = zeros(2, tlen);

