% HPSearch2c_plotCurve.m
%------------------------------------------------------------------------
% 
% Script for plotting responses. 
% This script is called from HPSearch2c_Curve of HPSearch2c.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Felix Dollack
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch2a_plotCurve): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_plotCurve): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_plotCurve): Jan 2015 by GA
%  --- faster plotting was enabled by FD 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Following variables should be defined in HPSearch2c_Curve.m
% 
% curveX = sort(unique(x1(j))); % depvar1 of non-spont trials
% curveY = sort(unique(x2(j))); % depvar2 of non-spont trials
% curveN = zeros(length(curveX), length(curveY));
% curveM = zeros(length(curveX), length(curveY));
% curveV = zeros(length(curveX), length(curveY));
% curveC = {'k-', 'b-', 'g-', 'r-', 'c-', 'y-'};
% spontX = [ min(curveX) max(curveX) ];
% spontN = 0;
% spontM = 0;
% spontV = 0;
% spontC = 'mo-';
%------------------------------------------------------------------------

% if tone PH with fixed freq, then plot phase histogram
if strcmp(upper(params.curvetype), 'PH') ...
    && strcmp(upper(curve.stimtype), 'TONE') ...
    && ~strcmp(upper(loopvars{1}), 'FREQ'); 

    nbin = 40;
    % if spont, then do nothing
    if ~stimcache.isspont(sindex) 
        % use spontN for counting spikes
        [ vs, prob, ntot, xbin, nspikes ] = ...
            TytoView_calcVS(tvec(a_spidx), params.Freq(1), nbin);
        spontN = spontN + nspikes;

        % plot curve data
        if plotparams.plotCurve

            set( handles.axesCurve, 'NextPlot', 'replace' ); % = hold off 

            % plot phase histogram
            bar( handles.axesCurve, xbin, spontN, 1);
            
            % set X/Y limits
            set( handles.axesCurve, 'xlim', [0,1]);
            set( handles.axesCurve, 'YlimMode', 'auto');

        end

    end

else % if not tone PH, then plot regular curves

    % calculate curve data
    if stimcache.isspont(sindex) 
        spontN = spontN + 1;
        spontM = spontM + a_rate;
        spontV = spontV + a_rate*a_rate;
    else
        if isnan(stimcache.loopvar(sindex,1))
            jx = 1;
        else
            jx = find( curveX == stimcache.loopvar(sindex,1));
        end
        if isnan(stimcache.loopvar(sindex,2))
            jy = 1;
        else
            jy = find( curveY == stimcache.loopvar(sindex,2));
        end
        curveN(jx,jy) = curveN(jx,jy) + 1;
        curveM(jx,jy) = curveM(jx,jy) + a_rate;
        curveV(jx,jy) = curveV(jx,jy) + a_rate*a_rate;
    end

    % plot curve data
    if plotparams.plotCurve

        set( handles.axesCurve, 'NextPlot', 'replace' ); % = hold off 

        % spont data
        if spontN > 0 
            m = spontM / spontN;
            s = sqrt( (spontV / spontN) - m * m );
            plot( handles.axesCurve, spontX, [m m], spontC );
        %%%  errorbar() is time-consuming so use plot() instead
        %    errorbar(spontX, [m m], [s s], spontC);  
        else
            cla(handles.axesCurve);
        end
        set( handles.axesCurve, 'NextPlot', 'add' );

        % curve data
        m = curveM ./ curveN;
        s = sqrt( (curveV ./ curveN) - m .* m );
        for jy = 1:length(curveY)
            plot(handles.axesCurve, curveX, m(:,jy), curveC{mod(jy,6)+1})
        %%%  errorbar() is time-consuming so use plot() instead
        %  errorbar(curveX, m(:,jy), s(:,jy), curveC{mod(jy,6)+1});  
        end

        % set X/Y limits
        set( handles.axesCurve, 'XlimMode', 'auto');
        set( handles.axesCurve, 'YlimMode', 'auto');
        set( handles.axesCurve, 'NextPlot', 'replace' ); % = hold off 

    end

end
