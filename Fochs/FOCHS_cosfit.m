function [ amp9, fq9, ph9 ] = FOCHS_cosfit(rvec, f, fs, stimtype) 
% [ amp9, fq9, ph9 ] = FOCHS_cosfit(rvec, f, fs, stimtype) 
%------------------------------------------------------------------------
% 
% Calculate cosine fitting
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version (FOCHS_cosfit): May 2012 (GA)
%------------------------------------------------------------------------

n = length(rvec); 

% default stimtype = 'TONE'
if nargin < 4
    stimtype = 'TONE';
end

% find out the locking frequency
switch upper(stimtype)
    case 'TONE' % use default freq if tone 
        fq9 = f;

    otherwise % use fft to estimate freq 
        farray = (0:n-1) * (fs/n); 
        rfft = abs(fft(rvec));
        [m,i] = max(rfft); 
        fq9 = farray(i); 
    end

% calculate amplitude 
tvec = (0:n-1) / fs; % [sec]
pvec = 2 * pi * fq9 * tvec; % [rad]
c = 2 * sum( rvec .* cos(pvec) ) / n;
s = 2 * sum( rvec .* sin(pvec) ) / n;
amp9 = sqrt( c*c + s*s ); 

% calculate phase 
if amp9 > 0
    ph9 = atan2(s,c);
else
    ph9 = 0;  % for zero vector
end


