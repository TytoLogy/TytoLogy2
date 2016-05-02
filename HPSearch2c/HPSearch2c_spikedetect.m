function idx = HPSearch2c_spikedetect(resp, thval, dwin, peak)
%------------------------------------------------------------------------
% idx = HPSearch2c_spikedetect(resp, thres, dwin, peak)
%------------------------------------------------------------------------
% 
% Funtion for detecting spikes
%
%------------------------------------------------------------------------
% Input Arguments:
%   resp      [1xL] recorded waveform (L:length of recording)
%   thval     spike threshold 
%   dwin      window size (in samples) 
%             -- doublets within this window will be counted as single
%             -- if dwin<=0 then no elimination is done
%   peak      1:detects top, -1:detects bottom, (default):top 
%
% Output Argument:
%   idx    [1xL] vector: idx(k)=1, if spike; idx(k)=0, otherwise 
% 
% Tech notes: 
%   Waveform 'peaks' that are higher than the threshold are detected as spikes. 
%   Threshold is set as multiple of the standard deviation of the waveform.
%   Negative threshold means the 'bottom detection' instead of the 'peak detection'
% 

%------------------------------------------------------------------------
%  Go Ashida 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch2_spikedetect): Nov 2011 by GA
% Adopted with modification HPSearch2a_spikedetect: Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_spikedetect): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_spikedetect): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

if nargin < 4
    peak = 0; % default 
end

% make an empty array for spike timings
idx = [];

% peak detection
r1 = [ resp(1), resp(1:end-1) ]; % shifted forward
r9 = [ resp(2:end), resp(end) ]; % shifted backward
idxp = ( (r1<resp) & (r9<resp) & (thval<resp) ); % peak timings 
idxb = ( (r1>resp) & (r9>resp) & (thval>resp) ); % bottom timings

% use top or bottom according to the 'peak' parameter
% if peak = 0, then use 'thval' to determine top/bottom
if peak < 0  % use bottom
    idx = idxb;
elseif peak > 0 % use peak
    idx = idxp;
elseif thval < 0 % use bottom
    idx = idxb;
else % use peak 
    idx = idxp; 
end

% deleting doublets 
if dwin > 0
    a = conv(idx*1, [ ones(1,dwin-1), 0] );
    b = a(dwin:end);
    c = ~(b>0);  % make rejection window
    idx = idx & c; 
end

