function outcaldata = HPSearch2_interpcal(incaldata, lfreq, hfreq)
%------------------------------------------------------------------------
% outcaldata = HPSearch2interpcal(incaldata, lfreq, hfreq)
%------------------------------------------------------------------------
% 
% Function to restrict caldata within specified frequency interval
%
%------------------------------------------------------------------------
% Input Arguments:
%   incaldata    calibration data created by HPSearch2_margecal
%   lfreq      freq lower limit
%   hfreq      freq upper limit
%
%  --- caldata should contain following fields
%    Freqs, mag, phase_us 
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
% Created (HPSearch2_interpcal): 18 March, 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

if lfreq < min(incaldata.freq) 
    outcaldata = [];
    return;
end
if hfreq > max(incaldata.freq) 
    outcaldata = [];
    return;
end

% adding small allowances
f1 = max([lfreq-10,  min(incaldata.freq)]);
f2 = min([hfreq+100, max(incaldata.freq)]);

% output frequencies
findex = (incaldata.freq >= lfreq) & (incaldata.freq <= hfreq); 
outcaldata.freq = sort( unique( [ f1 lfreq incaldata.freq(findex) hfreq f2 ] ) );

% interpolate L data 
outcaldata.mag(1,:) = interp1(incaldata.freq, incaldata.mag(1,:), outcaldata.freq);
outcaldata.phase_us(1,:) = interp1(incaldata.freq, incaldata.phase_us(1,:), outcaldata.freq);
outcaldata.mindbspl(1) = min( outcaldata.mag(1,:) );
outcaldata.maginv(1,:) = invdb( outcaldata.mindbspl(1) - outcaldata.mag(1,:) ); 

% interpolate R data 
outcaldata.mag(2,:) = interp1(incaldata.freq, incaldata.mag(2,:), outcaldata.freq);
outcaldata.phase_us(2,:) = interp1(incaldata.freq, incaldata.phase_us(2,:), outcaldata.freq);
outcaldata.mindbspl(2) = min( outcaldata.mag(2,:) );
outcaldata.maginv(2,:) = invdb( outcaldata.mindbspl(2) - outcaldata.mag(2,:) ); 

% DAscale
outcaldata.DAscale = incaldata.DAscale;

