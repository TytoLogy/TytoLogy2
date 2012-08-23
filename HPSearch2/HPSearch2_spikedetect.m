function [idx, thval] = HPSearch2_spikedetect(resp, thres, dwin, refresp)
%------------------------------------------------------------------------
% [idx, thval] = HPSearch2_spikedetect(resp, thres, dwin, varargin)
%------------------------------------------------------------------------
% 
% Funtion for detecting spikes
%
%------------------------------------------------------------------------
% Input Arguments:
%   resp      [1xL] recorded waveform (L:length of recording)
%   thres     spike threshold (x Standard Deviation)
%   dwin      window size (in samples) 
%             -- doublets within this window will be counted as single
%             -- if dwin<=0 then no elimination is done
%   refresp   reference waveform (optional)
%             -- if refresp does not exist, then resp is used
% 
% Output Arguments:
%   idx    [1xL] vector: idx(k)=1, if spike; idx(k)=0, otherwise 
%   thval     threshold value
% 
% Tech notes: 
%   Waveform peaks that are higher than the threshold are detected as spikes. 
%   Threshold is set as multiple of the standard deviation of the waveform.
%   Negative threshold means the 'bottom detection' instead of the 'peak detection'
% 
%   EXAMPLE: 
%     If thres=3, peaks that exceed 3x standard deviation of the waveform 
%     are detectedas spikes. If thres=-2.5, negative peaks (=bottoms) that 
%     are lower than the 2.5xSD are counted. 
%     

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created (HPSearch2_spikedetect): 11 November, 2011 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

idx = [];
nsp = 0;

if nargin < 4 
    thval = std(resp) * abs(thres);
else
    thval = std(refresp) * abs(thres);
end

% peak detection
r1 = [ resp(2:end), resp(end) ]; % shifted forward
r9 = [ resp(2:end), resp(end) ]; % shifted backward
idxp = ( (r1<resp) & (r9<resp) & ( thval<resp) );  
idxb = ( (r1>resp) & (r9>resp) & (-thval>resp) ); 

if thres < 0  % use bottom
    idx = idxb;
else % use peak
    idx = idxp;
end

% deleting doublets 
if dwin > 0
    a = conv(idx, [ ones(1,dwin-1), 0] );
    b = a(dwin:end);
    c = ~(b>0);  % make rejection window
    idx = idx & c; 
end


