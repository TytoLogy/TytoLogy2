function outcaldata = HPSearch2_mergecal(LeftOn, RightOn, caldataL, caldataR)
%------------------------------------------------------------------------
% outcaldata = HPSearch2_mergecal(LeftOn, RightOn, caldataL, caldataR)
%------------------------------------------------------------------------
% 
% Function to merge L and R caldata into one
%
%------------------------------------------------------------------------
% Input Arguments:
%   LeftOn      flag to show if LEFT channel is on (on:1, off:0)
%   RightOn     flag to show if RIGHT channel is on (on:1, off:0)
%	caldataL    calibration data for LEFT created by HPSearch2_loadcal
%   caldataR    calibration data for RIGHT created by HPSearch2_loadcal
%
%  --- caldataL and caldata R should contain following fields
%    Freqs, mag, phase, phase_us, mindbspl, maxdbspl, maginv, DAlevel
%    
%   
% Output Arguments:
%  outdalcata   merged calibration data in HPSearch format
%
%  --- notes ---
%  caldata.freq, caldata.maginv, and caldata.phase-us will be used 
%  in figure_cal() called by syn_headphonenoise_fft() called 
%  by syn_headphonenoise() called by HPSearch2_Search. 
% 
%  caldata.mindbspl will be used in figure_headphone_atten() called 
%  by HPSearch2_search_calcatten called by HPSearch2_Search.

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created (HPSearch2_mergecal): 11 November, 2011 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

dummydata.Freqs = [0 100000 200000];
dummydata.mag   = [110 110 110];
dummydata.phase = [0 0 0];
dummydata.phase_us = [0 0 0];
dummydata.mindbspl = min(dummydata.mag);
dummydata.maxdbspl = max(dummydata.mag);
dummydata.maginv = invdb(dummydata.mindbspl - dummydata.mag); % =[1 1 1]
dummydata.DAlevel = 5;

if LeftOn && RightOn % both channels are ON
    c1 = caldataL;
    c2 = caldataR;
elseif LeftOn && ~RightOn % LEFT is ON, RIGHT is OFF
    c1 = caldataL;
    c2 = dummydata;
elseif ~LeftOn && RightOn % LEFT is OFF, RIGHT is ON
    c1 = dummydata;
    c2 = caldataR;
else % both channels are OFF
    c1 = dummydata;
    c2 = dummydata;
end

% first, calculate freq array
f1 = c1.Freqs; 
f2 = c2.Freqs;
fmax = min( max(f1), max(f2) );
fmin = max( min(f1), min(f2) );
f3 = sort( unique ( [f1 f2] ) ); % merged f1 and f2
outcaldata.freq = f3( (fmin<=f3) & (f3<=fmax) ); % check max and min

% correct magnitude if original DAlevel is not 5
outcaldata.DAscale = 5;
m1 = c1.mag + db( outcaldata.DAscale / c1.DAlevel ); 
m2 = c2.mag + db( outcaldata.DAscale / c2.DAlevel ); 

% interpolate L data 
outcaldata.mag(1,:) = interp1(f1, m1, outcaldata.freq);
outcaldata.phase_us(1,:) = interp1(f1, c1.phase_us, outcaldata.freq);
outcaldata.mindbspl(1) = min( outcaldata.mag(1,:) );
outcaldata.maginv(1,:) = invdb( outcaldata.mindbspl(1) - outcaldata.mag(1,:) ); 

% interpolate R data 
outcaldata.mag(2,:) = interp1(f2, m2, outcaldata.freq);
outcaldata.phase_us(2,:) = interp1(f2, c2.phase_us, outcaldata.freq);
outcaldata.mindbspl(2) = min( outcaldata.mag(2,:) );
outcaldata.maginv(2,:) = invdb( outcaldata.mindbspl(2) - outcaldata.mag(2,:) ); 


