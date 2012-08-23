function TytoView_clickplot(clickdata, clicksettings, w)
%------------------------------------------------------------------------
% TytoView_clickplot.m
%------------------------------------------------------------------------
%  for plotting Click data
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 15 March, 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

% extract file name
[pathstr, filestr, extstr] = fileparts(clicksettings.clicksettingsfile);

% loop variables
itd = clickdata.itd_sort;

%----------------------------------------------------------
% if itd was varied, then plot itd response curve
%----------------------------------------------------------
if length(itd) > 1

    % calculate mean and std of spike rates 
    y = clickdata.spike_counts;
    m = mean(y,2);  % average wrt 2nd index
    s = std(y,1,2); % std wrt 2nd index 
    x = itd(:,1);

    % now plot
    figure;
    hold off;
    errorbar(x, m, s, 'bo-');
    xlabel('ITD (us)');
    ylabel('# spikes');
    title(filestr);
    drawnow;

end

%----------------------------------------------------------
% plot PSTH
%----------------------------------------------------------

% bin width
if nargin < 3
    wbin = 0.2; % (ms) default
else
    wbin = w;
end

% calculate psth
nbin = round(clicksettings.stim.Duration / wbin);
xbin = ((1:nbin)-0.5) * wbin;

sptimes = horzcat(clickdata.spike_times{:});
nspikes = zeros(1,nbin);
for i = 1:nbin
    t0 =  (i-1) * wbin; 
    t1 =    i   * wbin; 
    nspikes(i) = sum( (sptimes >= t0) & (sptimes<t1) );
end

% now plot
figure;
bar(xbin, nspikes, 1);
%xlim([]);
xlabel('time (ms)');
ylabel('# spike counts');
title([ filestr ] );
drawnow;

