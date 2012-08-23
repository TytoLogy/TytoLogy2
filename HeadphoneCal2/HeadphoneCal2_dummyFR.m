function out = HeadphoneCal2_dummyFR(varargin)
%------------------------------------------------------------------------
% out = MicrophonCal2_dummyFR(varargin)
%------------------------------------------------------------------------
% 
% Sets FR data for unused side
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: November, 2011 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

out.version = '2.0';
out.F = [0,100000,200000];  % Fmin=0, Fstep=100000, Fmax=200000;
out.Freqs = out.F(1):out.F(2):out.F(3);
out.Nfreqs = length(out.Freqs);
out.DAlevel = 0; 
out.adjmag = ones(1, out.Nfreqs);
out.adjphi = zeros(1, out.Nfreqs); 
out.cal = struct();
out.cal.RefMicSens = 1;
out.cal.MicGain_dB = 0;
