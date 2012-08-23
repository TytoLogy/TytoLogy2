function FOCHS_simpleplot(curvedata, curvesettings)
%------------------------------------------------------------------------
% FOCHS_simpleplot.m
%------------------------------------------------------------------------
%  for plotting Curve data
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version (TytoView_simpleplot): March 2012 by GA
% Four-Channel Version (FOCHS_simpleplot): May 2012 by GA
%------------------------------------------------------------------------

%----------------------------------------------------------
% extracting data
%----------------------------------------------------------
% extract file name
[pathstr, filestr, extstr] = fileparts(curvesettings.curvesettingsfile);

% loop variables
x1 = curvedata.depvars_sort(:,1,1);
x2 = curvedata.depvars_sort(:,1,2);

% calculate mean and std of spike rates 
y = curvedata.fit_amp * 1000; % [mV] 
m1 = mean(y,3);  % average wrt 2nd index (=rep)
s1 = std(y,1,3); % std wrt 2nd index (=rep) 

% data for non-spont trials
j = (curvedata.isspont(:,1)==0); % find out non-spont trials
x = x1(j);
m = m1(:,j);
s = s1(:,j);

% data for spont trials
jsp = (curvedata.isspont(:,1)==1); % find out spont trials
msp = m1(:,jsp);
ssp = s1(:,jsp);

%----------------------------------------------------------
% plot according to the number of loop variables
%----------------------------------------------------------
if curvesettings.stimcache.nloopvars == 0

    % assign all data to x=1...4 and plot
    figure;
    cla;
    hold on;
    errorbar(1*ones(size(x)), m(1,:), s(1,:), 'bo-');
    errorbar(2*ones(size(x)), m(2,:), s(2,:), 'ro-');
    errorbar(3*ones(size(x)), m(3,:), s(3,:), 'go-');
    errorbar(4*ones(size(x)), m(4,:), s(4,:), 'mo-');
    if ~isempty(msp); 
        errorbar(1, msp(1), ssp(1), 'b*-')
        errorbar(2, msp(2), ssp(2), 'r*-')
        errorbar(3, msp(3), ssp(3), 'g*-')
        errorbar(4, msp(4), ssp(4), 'm*-')
    end
    hold off;
    xlabel('');
    ylabel('# amplitude (mV)');
    title(filestr);
    drawnow;

elseif curvesettings.stimcache.nloopvars == 1

    % plot data
    figure;
    cla;
    hold on;
    errorbar(x, m(1,:), s(1,:), 'bo-');
    errorbar(x, m(2,:), s(2,:), 'ro-');
    errorbar(x, m(3,:), s(3,:), 'go-');
    errorbar(x, m(4,:), s(4,:), 'mo-');
    if ~isempty(msp)
        errorbar([min(x) max(x)], [msp(1) msp(1)], [ssp(1) ssp(1)], 'b*-');
        errorbar([min(x) max(x)], [msp(2) msp(2)], [ssp(2) ssp(2)], 'r*-');
        errorbar([min(x) max(x)], [msp(3) msp(3)], [ssp(3) ssp(3)], 'g*-');
        errorbar([min(x) max(x)], [msp(4) msp(4)], [ssp(4) ssp(4)], 'm*-');
    end
    hold off;
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('# amplitude (mV)');
    title(filestr);
    drawnow;

elseif curvesettings.stimcache.nloopvars == 2

    % strings for colors
    c = {'k-', 'b-', 'g-', 'r-', 'c-', 'y-'};

    % get dependent variables (without spont)
    v1 = sort( unique(x1(j) ) );
    v2 = sort( unique(x2(j) ) );

    % plotting
    figure;

    % loop through channels
    for ch = 1:4

    % matrix to store mean amps
    m = zeros(length(v1),length(v2));
    s = zeros(length(v1),length(v2));
    tmpstr = '';
    for i2 = 1:length(v2)
        m(:,i2) = m1( ch, x2==v2(i2) );
        s(:,i2) = s1( ch, x2==v2(i2) );
        tmpstr = [ tmpstr ', ' num2str(v2(i2))];
    end

    subplot(4,2,ch*2-1);
    % plot spont 
    if ~isempty(msp)
        errorbar([min(x) max(x)], [msp(ch) msp(ch)], [ssp(ch) ssp(ch)], 'mo-')
    end
    hold on;
    % plot data
    for i2 = 1:length(v2)
        errorbar(v1, m(:,i2), s(:,i2), c{mod(i2,6)+1} );
    end
    hold off;
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('# amplitude (mV)');
    title([filestr ': channel ' num2str(ch) ':' tmpstr]);
    drawnow;

    % plotting normalized data
    subplot(4,2,ch*2);
    % plot data
    for i2 = 1:length(v2)
        mx = max(m(:,i2));
        plot(v1, m(:,i2)/mx*100, c{mod(i2,6)+1} );
        hold on;
    end
    hold off;
    xlabel(curvesettings.stimcache.loopvars{1});
    ylabel('normalized response (%)');
    title([filestr ': channel ' num2str(ch) ':' tmpstr]);
    drawnow;

    end % for ch = 1:4

else 
    warndlg('Something wrong with loop variables. Abort plotting curve'); 
end

