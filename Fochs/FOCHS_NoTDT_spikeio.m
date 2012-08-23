function [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4] = ...
    FOCHS_NoTDT_spikeio(stim, inpts, indev, outdev, zBUS)
% [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4] = ...
%    FOCHS_NoTDT_spikeio(stim, inpts, indev, outdev, zBUS)
%------------------------------------------------------------------------
%
% Dummy function to used with the NO_TDT configuration
% Returns dummy response data
%
%------------------------------------------------------------------------
% Input Arguments:
%   stim    [2xN] stereo output signal (row1 = left, row2 = right)
%   inpts   number of points to acquire
%   indev   TDT device interface structure for input & output
%   outdev  TDT device interface structure for output (not used)
%   zBUS    TDT device interface structure for zBUS (not used)
% 
% Output Arguments:
%   respX    [1xinpts] input data vector (X=1-4)
%   nptsX    number of data points read (X=1-4)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida
%   ashida@umd.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (HPSearch2_NoTDT_spikeio): Feb 2012 by GA
% Four-channel Input Version (FOCHS_NoTDT_spikeio): May 2012 by GA  
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% this function is called by FOCHS_Search as:  
%  [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4] = ...
%      handles.h2.config.ioFunc(S, acqpts, indev, outdev, zBUS);
%------------------------------------------------------------------------
% inpts:  acqpts = ms2samples(tdt.AcqDuration, inFs);
% outpts: outpts = ms2samples(stimulus.Duration, outFs);
%------------------------------------------------------------------------

% loading the notdt structure (containing stimulus, tdt, Fs)
load notdt.mat; 
nFs = notdt.Fs;  % inFs=Fs(1), outFs=Fs(2)
nDelay = ms2samples(notdt.stimulus.Delay, nFs(2));
clear notdt; 

% introduce delay
outstim = [ zeros(2,nDelay), stim ]; 
outpts = length(outstim);

% make a stim vector with a length of inpts
instim = zeros(2,inpts);

% copy from outstim to instim according to their lengths  
if inpts < outpts 
    instim(1,1:inpts) = outstim(1,1:inpts); 
    instim(2,1:inpts) = outstim(2,1:inpts); 
else
    instim(1,1:outpts) = outstim(1,1:outpts); 
    instim(2,1:outpts) = outstim(2,1:outpts); 
end

% calculate amplitudes
amp = std(stim,0,2); 

if amp(1)==0 && amp(2)==0 
    a1 = 0.1;
    a2 = 0.1;
elseif amp(1)==0 && amp(2)>0 
    a1 = amp(2)*0.1;
    a2 = amp(2);
elseif amp(1)>0 && amp(2)==0 
    a1 = amp(1);
    a2 = amp(1)*0.1;
else % amp(1)>0 && amp(2)>0
    a1 = amp(1);
    a2 = amp(2);
end

% make random vectors 
r1 = 0.5 * a1 * randn(1,inpts); 
r2 = 0.5 * a2 * randn(1,inpts); 
r3 = 0.5 * max([a1,a2]) * randn(1,inpts); 
r4 = 0.5 * min([a1,a2]) * randn(1,inpts); 

% make result vectors
ascale = 0.001;
resp1 = ascale * ( r1 + instim(1,:) );
resp2 = ascale * ( r2 + instim(2,:) );
resp3 = ascale * ( r3 + instim(1,:) + instim(2,:) );
resp4 = ascale * ( r4 + instim(1,:) - instim(2,:) );

% all nptsX = inpts
npts1 = inpts;
npts2 = inpts;
npts3 = inpts;
npts4 = inpts;
