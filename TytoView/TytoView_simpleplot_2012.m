function TytoView_simpleplot_2012(curvedata, curvesettings, w)
%------------------------------------------------------------------------
% TytoView_simpleplot.m
%------------------------------------------------------------------------
%  for plotting Curve data
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 15 March, 2012 by GA
%
% Revisions: 
%     added VS calculation for sAM: 29 Nov, 2012 by GA
% 
%------------------------------------------------------------------------

%----------------------------------------------------------
% extracting data
%----------------------------------------------------------
% time length of analysis time window
tlen = curvesettings.analysis.EndTime - curvesettings.analysis.StartTime;

% extract file name
[pathstr, filestr, extstr] = fileparts(curvesettings.curvesettingsfile);

% loop variables
x1 = curvedata.depvars_sort(:,1,1);
x2 = curvedata.depvars_sort(:,1,2);

% calculate mean and std of spike rates 
y = curvedata.spike_counts * 1000 / tlen; 
m1 = mean(y,2);  % average wrt 2nd index
s1 = std(y,1,2); % std wrt 2nd index 

% data for non-spont trials
j = (curvedata.isspont(:,1)==0); % find out non-spont trials
x = x1(j);
m = m1(j);
s = s1(j);

% data for spont trials
jsp = (curvedata.isspont(:,1)==1); % find out spont trials
msp = m1(jsp);
ssp = s1(jsp);

%----------------------------------------------------------
% plot according to the number of loop variables
%----------------------------------------------------------
if curvesettings.stimcache.nloopvars == 0

    % assign all data to x=0 and plot
    figure;
    errorbar(zeros(size(x)), m, s, 'bo-');
    hold on;
    if ~isempty(msp)
        errorbar(0, msp, ssp, 'mo-')
    end
    hold off;
    xlabel('');
    ylabel('# spikes per sec');
    title(filestr);
    drawnow;

elseif curvesettings.stimcache.nloopvars == 1

    % plot data
    figure;
    errorbar(x, m, s, 'bo-');
    hold on;
    if ~isempty(msp)
        errorbar([min(x) max(x)], [msp msp], [ssp ssp], 'mo-')
    end
    hold off;
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('# spikes per sec');
    title(filestr);
    drawnow;

elseif curvesettings.stimcache.nloopvars == 2

    % strings for colors
    c = {'k-', 'b-', 'g-', 'r-', 'c-', 'y-'};

    % get dependent variables (without spont)
    v1 = sort( unique(x1(j) ) );
    v2 = sort( unique(x2(j) ) );

    % matrix to store mean rates
    m = zeros(length(v1),length(v2));
    s = zeros(length(v1),length(v2));
    tmpstr = '';
    for i2 = 1:length(v2)
        m(:,i2) = m1( x2==v2(i2) );
        s(:,i2) = s1( x2==v2(i2) );
        tmpstr = [ tmpstr ', ' num2str(v2(i2))];
    end

    % plotting
    figure;

    subplot(2,1,1);
    % plot spont 
    if ~isempty(msp)
        errorbar([min(x) max(x)], [msp msp], [ssp ssp], 'mo-')
    end
    hold on;
    % plot data
    for i2 = 1:length(v2)
        errorbar(v1, m(:,i2), s(:,i2), c{mod(i2,6)+1} );
    end
    hold off;
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('# spikes per sec');
    title([filestr tmpstr]);
    drawnow;

    % plotting normalized data
    subplot(2,1,2);
    % plot data
    for i2 = 1:length(v2)
        mx = max(m(:,i2));
%        errorbar(v1, m(:,i2)/mx*100, s(:,i2)/mx*100, c{mod(i2,6)+1} );
        plot(v1, m(:,i2)/mx*100, c{mod(i2,6)+1} );
        hold on;
    end
    hold off;
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('normalized response (%)');
    title([filestr tmpstr]);
    drawnow;

else 
    warndlg('Something wrong with loop variables. Abort plotting curve'); 
end

%----------------------------------------------------------
% plot PSTH 
%----------------------------------------------------------

% bin width
if nargin < 3
    wbin = 1.0; % (ms) default
else
    wbin = w;
end

% calculate psth
%nbin = round(curvesettings.tdt.AcqDuration / wbin);
nbin = round(curvesettings.stim.Duration / wbin);
xbin = ((1:nbin)-0.5) * wbin;

allspiketimes = horzcat(curvedata.spike_times{(curvedata.isspont==0)});
sptimes = allspiketimes - curvesettings.stim.Delay;
ntot = length(sptimes); 

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
ptxt = sprintf('%s, N= %.0f', filestr, ntot);
title(ptxt);
drawnow;

%----------------------------------------------------------
% if tone with single freq is used, calculate phase histograms 
%----------------------------------------------------------
if strcmp(curvesettings.stimcache.stimtype, 'TONE') ...
    && ~strcmp(curvesettings.stimcache.loopvars{1}, 'FREQ') ...
    && ~strcmp(curvesettings.stimcache.loopvars{2}, 'FREQ') 

    % extract frequency from the data structure
    tmpfreq = sort( unique( vertcat( curvesettings.stimcache.Freq{:} ) ) );
    if curvesettings.curve.Spont
        freq = tmpfreq(2); % tmpfreq(1) should be spont (-99999)
    else
        freq = tmpfreq(1);
    end

    % calculate vector strength
    nbin = 60;
    allspiketimes = horzcat(curvedata.spike_times{(curvedata.isspont==0)});
    [ vs, prob, ntot, xbin, nspikes ] = ...
        TytoView_calcVS(allspiketimes, freq, nbin);

    % figure caption to show vs and prob
    if ~isempty(prob)
        ptxt = sprintf('VS= %.4f, N= %.0f, P= %.6f', vs, ntot, prob);
    else 
        ptxt = sprintf('VS= %.4f, N= %.0f, P= ????', vs, ntot);
    end

    % now plot
    figure;
    bar(xbin, nspikes, 1);
    xlim([0,1]);
    xlabel('phase (cycle)');
    ylabel('# spike counts');
    title([ filestr ' : ' ptxt ] );
    drawnow;

% plot multiple phase histograms when ABI is varied
if strcmp(curvesettings.stimcache.loopvars{1}, 'ABI') ... 
 
    figure;
    % calculate vector strength
    nbin = 60;

    for i1=1:length(x1) 

        % calculate VS
        allspiketimes = horzcat( curvedata.spike_times{ ( curvedata.depvars_sort(:,:,1)==x1(i1) ) } );
        [ vs, prob, ntot, xbin, nspikes ] = ...
            TytoView_calcVS(allspiketimes, freq, nbin);

        % figure caption to show vs and prob
        if ~isempty(prob)
            ptxt = sprintf('ABI=%.0f, VS= %.3f, N= %.0f, P= %.4f', x1(i1), vs, ntot, prob);
        else 
            ptxt = sprintf('ABI=%.0f, VS= %.3f, N= %.0f, P= ????', x1(i1), vs, ntot);
        end

        % now plot
        ncol = floor( sqrt(length(x1)) );
        subplot( ceil(length(x1)/ncol), ncol, i1); 
        bar(xbin, nspikes, 1);
        xlim([0,1]);
        xlabel('');
        ylabel('# spike counts');
        title(ptxt);

    end
    drawnow

end

end

%----------------------------------------------------------
% if AM is used, make phase histograms with the envelope 
%   freq and calculate VS values
% --- added Nov 28, 2012 by GA
%----------------------------------------------------------

if max(curvesettings.stimcache.sAMp) > 0

    % make bins and an array for vector strength
    nbin = 60;
    vsa = zeros(1,length(x1));
    figure;

    % make freq array according to the loopvar setting
    if strcmp(upper(curvesettings.stimcache.loopvars{1}), 'SAMP')

        % extract frequency from the data structure
        tmpfreq = sort( unique( curvesettings.stimcache.sAMf ) );

        % get freq
        if curvesettings.curve.Spont % tmpfreq(1) should be spont (-99999)
            freq = ones(1,length(x1))*tmpfreq(2); 
        else
            freq = ones(1,length(x1))*tmpfreq(1);
        end

    elseif strcmp(upper(curvesettings.stimcache.loopvars{1}), 'SAMF') 

        %$ if SAMF then the depvar(=x1) is the freq
        freq = x1;

    end

    % calculate VS and plot
    for i1=1:length(x1) 

        % calculate vector strength
        allspiketimes = horzcat( curvedata.spike_times{ ( curvedata.depvars_sort(:,:,1)==x1(i1) ) } );
        [ vs, prob, ntot, xbin, nspikes ] = ...
            TytoView_calcVS(allspiketimes, freq(i1), nbin);
        vsa(i1) = vs; % store VS data

        % figure caption to show vs and prob
        if ~isempty(prob)
            ptxt = sprintf('%s=%.0f, VS= %.3f, N= %.0f, P= %.4f', ...
                curvesettings.stimcache.loopvars{1}, x1(i1), vs, ntot, prob);
        else 
            ptxt = sprintf('%s=%.0f, VS= %.3f, N= %.0f, P= ????', ...
                curvesettings.stimcache.loopvars{1}, x1(i1), vs, ntot);
        end

        % now plot
        ncol = floor( sqrt(length(x1)) );
        subplot( ceil(length(x1)/ncol), ncol, i1); 
        bar(xbin, nspikes, 1);
        xlim([0,1]);
        xlabel('');
        ylabel('# spike counts');
        title(ptxt);

    end
    drawnow;

    % plot VS curve
    figure;
    plot(x1(x1~=-99999), vsa(x1~=-99999), 'bo-');
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('VS (locked to envelope)');
    ylim([0 1]);
    title(filestr);
    drawnow;

end






%%%%%%%%%%%%%%%%%%%%%%%
%%%% older version %%%%
%%%%%%%%%%%%%%%%%%%%%%%
% if max(curvesettings.stimcache.sAMp) > 0
% 
%     if strcmp(upper(curvesettings.stimcache.loopvars{1}), 'SAMP')
% 
%         % extract frequency from the data structure
%         tmpfreq = sort( unique( curvesettings.stimcache.sAMf ) );
% 
%         % get freq
%         if curvesettings.curve.Spont
%             freq = tmpfreq(2); % tmpfreq(1) should be spont (-99999)
%         else
%             freq = tmpfreq(1);
%         end
% 
%         % calculate vector strength
%         nbin = 60;
%         allspiketimes = horzcat(curvedata.spike_times{(curvedata.isspont==0)});
%         [ vs, prob, ntot, xbin, nspikes ] = ...
%             TytoView_calcVS(allspiketimes, freq, nbin);
% 
%         % figure caption to show vs and prob
%         if ~isempty(prob)
%             ptxt = sprintf('sAM VS= %.4f, N= %.0f, P= %.6f', vs, ntot, prob);
%         else 
%             ptxt = sprintf('sAM VS= %.4f, N= %.0f, P= ????', vs, ntot);
%         end
% 
%         % now plot
%         figure;
%         bar(xbin, nspikes, 1);
%         xlim([0,1]);
%         xlabel('envelope phase (cycle)');
%         ylabel('# spike counts');
%         title([ filestr ' : ' ptxt ] );
%         drawnow;
% 
%     % if AM freq or amp is varied, then make multiple plots
%     elseif strcmp(upper(curvesettings.stimcache.loopvars{1}), 'SAMF') 
% 
%         % make bins and an array for vector strength
%         nbin = 60;
%         figure;
% 
%         for i1=1:length(x1) 
% 
%             % get freq
%             freq = x1(i1);
% 
%             % calculate VS
%             allspiketimes = horzcat( curvedata.spike_times{ ( curvedata.depvars_sort(:,:,1)==x1(i1) ) } );
%             [ vs, prob, ntot, xbin, nspikes ] = ...
%                 TytoView_calcVS(allspiketimes, freq, nbin);
% 
%             % figure caption to show vs and prob
%             if ~isempty(prob)
%                 ptxt = sprintf('%s=%.0f, VS= %.3f, N= %.0f, P= %.4f', ...
%                             curvesettings.stimcache.loopvars{1}, x1(i1), vs, ntot, prob);
%             else 
%                 ptxt = sprintf('%s=%.0f, VS= %.3f, N= %.0f, P= ????', ...
%                             curvesettings.stimcache.loopvars{1}, x1(i1), vs, ntot);
%             end
% 
%             % now plot
%             ncol = floor( sqrt(length(x1)) );
%             subplot( ceil(length(x1)/ncol), ncol, i1); 
%             bar(xbin, nspikes, 1);
%             xlim([0,1]);
%             xlabel('');
%             ylabel('# spike counts');
%             title(ptxt);
% 
%        end
%        drawnow
%    end
% 
% end
% 
