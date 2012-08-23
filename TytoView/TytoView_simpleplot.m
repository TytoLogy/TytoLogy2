function TytoView_simpleplot(curvedata, curvesettings)
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

