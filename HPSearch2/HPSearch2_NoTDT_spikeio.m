function [resp, npts, respu, nptsu] = HPSearch2_NoTDT_spikeio(stim, inpts, indev, outdev, zBUS)
% [resp, idx, respu, nptsu] = HPSearch2_NoTDT_spikeio(stim, inpts, iodev, outdev, zBUS)
% 
% Dummy function to used with the NO_TDT configuration
% Returns dummy response data
% 
% Input Arguments:
% 	stim        [2xN] stereo output signal (row1 = left, row2 = right)
% 	inpts		number of points to acquire
% 	indev		TDT device interface structure for input (not used)
% 	outdev		TDT device interface structure for output (not used)
% 	zBUS		TDT device interface structure for zBUS (not used)
% 
% Output Arguments:
% 	resp	[1xinpts] input data vector (or 1Xindex if something weird happens
% 	npts	number of data points read (resp = channel A)
%   respu   [1xinpts] input data vector (unfiltered)
%   nptsu   number of data points read (respu = channel B)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created (HPSearch2_NoTDT_spikeio): Feb 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% this function is called by HPSearch2_Search as:  
% [resp, npts, respu, nptsu] = ...
%   handles.h2.config.ioFunc(S, acqpts, indev, outdev, zBUS);
%------------------------------------------------------------------------
% inpts:  acqpts = ms2samples(tdt.AcqDuration, inFs);
% outpts: outpts = ms2samples(stimulus.Duration, outFs);
%------------------------------------------------------------------------

load notdt.mat;  % loading the notdt structure
nFs = notdt.Fs;  % inFs=Fs(1), outFs=Fs(2)
nDelay = ms2samples(notdt.stimulus.Delay, nFs(2));
clear notdt; 

amp = std(stim,0,2); 
resp  = 1.0*amp(1)*randn(1,inpts);
respu = 1.0*amp(2)*randn(1,inpts);

outstim = [ zeros(2,nDelay), stim ]; % introducing delay
outpts = length(outstim);

if outpts > inpts
     resp  = resp  + outstim(1,1:inpts) + outstim(2,1:inpts);
     respu = respu + outstim(1,1:inpts) - outstim(2,1:inpts);  
else
     resp(1,1:outpts)  = resp(1,1:outpts)  + outstim(1,:) + outstim(2,:); 
     respu(1,1:outpts) = respu(1,1:outpts) + outstim(1,:) - outstim(2,:); 
end
 
npts = inpts;
nptsu = inpts;

