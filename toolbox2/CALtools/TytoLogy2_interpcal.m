function outcaldata = TytoLogy2_interpcal(incaldata, lfreq, hfreq)
%------------------------------------------------------------------------
% outcaldata = TytoLogy2_interpcal(incaldata, lfreq, hfreq)
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
%  --- incaldata should contain following fields:
%    Freqs, mag, phase_us 
%    
% Output Arguments:
%   outdalcata   merged calibration data in HPSearch format
%
%  --- notes ---
%  caldata.freq, caldata.maginv, and caldata.phase-us will be used in 
%  figure_cal() called by syn_headphonenoise_fft() called by syn_headphonenoise().  
%  caldata.mindbspl will be used in figure_headphone_atten() 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version (HPSearch2_interpcal): March 2012 by GA
% Generalized Version (TytoLogy2_interpcal): May 2012 by GA  
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

