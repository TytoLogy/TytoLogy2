function [resp, index] = HeadphoneCal2_NoTDT_calibation_io(iodev, stim, inpts)
% [resp, index] = HeadphoneCal2_NoTDT_calibration_io(iodev, stim, inpts)
% 
% Dummy function to used with the NO_TDT configuration
% Returns dummy response data
%
% Input Arguments:
% 	iodev	TDT input/output device interface structure
%	stim	[2XN] stimulus array, L channel in row 1, R channel in row 2
%	inpts	# of points to record from input channels (AcqPoints)
% 
% Output Arguments:
% 	resp	2 element response cell array
%	index	buffer size
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (HeadphoneCal2_NoTDT_calibration_io): Apr 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

load notdt.mat;  % loading the notdt structure
nCal = notdt.cal;
clear notdt; 

% find out which side is stimulated
amp = std(stim,0,2); 
if amp(1) > amp(2) 
    PSIDE = 1;
    SSIDE = 2;
    pmagadjval = nCal.frL.magadjval;
else
    PSIDE = 2;
    SSIDE = 1;
    pmagadjval = nCal.frR.magadjval;
end

pstim = stim(PSIDE,:);
sstim = stim(SSIDE,:);

% find out the stimulus frequency
nstim = length(pstim);
freqarray = (0:nstim-1)*(iodev.Fs/nstim);
fftstim = abs(fft(pstim));
[m,i] = max(fftstim); 
fbest = freqarray(i); 
findex1 = min( find(fbest<=nCal.Freqs) );
findex2 = max( find(fbest>=nCal.Freqs) );
freq1 = nCal.Freqs(findex1);
freq2 = nCal.Freqs(findex2);
if abs(fbest-freq1) < abs(fbest-freq2)
    freq = freq1; 
    findex = findex1;
else
    freq = freq2;
    findex = findex2;
end

% find out the dBSPL value
[pmag, pphi] = fitsinvec(pstim, 1, iodev.Fs, freq);
pmag = nCal.RMSsin * pmag / (nCal.MicGain(PSIDE) * pmagadjval(findex));
pmagdB = dbspl(nCal.VtoPa(PSIDE) * pmag);

% find out the target dBSPL
switch nCal.AttenType
    case 'VARIED' % go to loop below to fing the proper attenuation value
        targetdB = (nCal.MaxLevel-nCal.MinLevel+2)*rand + nCal.MinLevel-1;
    case 'FIXED'
        targetdB = 110-nCal.AttenFixed;
end

% find out the magnification factor
fmag = 10^( (targetdB-pmagdB)/20 );

% compose the resp array to return
respP = fmag * ( pstim*0.98 + sstim*0.02 ); 
respS = fmag * ( pstim*0.02 + sstim*0.98 );

resp{PSIDE} = fmag * 0.01* amp(PSIDE) * randn(1,inpts);
resp{SSIDE} = fmag * 0.01* amp(PSIDE) * randn(1,inpts);

nDelay = ms2samples(nCal.Delay, iodev.Fs);
outpts = length(pstim);

resp{PSIDE}(nDelay+1:nDelay+outpts) = ... 
    resp{PSIDE}(nDelay+1:nDelay+outpts) + respP;
resp{SSIDE}(nDelay+1:nDelay+outpts) = ... 
    resp{SSIDE}(nDelay+1:nDelay+outpts) + respS;

index = [inpts inpts];

