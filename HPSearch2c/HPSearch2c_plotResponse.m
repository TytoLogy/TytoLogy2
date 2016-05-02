% HPSearch2c_plotResponse.m
%------------------------------------------------------------------------
% 
% Script for plotting responses. 
% This script is called from either HPSearch2b_Search, HPSearch2b_Curve, 
% or HPSearch2c_Click of HPSearch2b.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Felix Dollack 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch2a_plotResponse): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_plotResponse): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_plotResponse): Jan 2015 by GA
%  --- faster plotting was enabled by FD 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Following variables are assumed to be defined before calling this script
%  
% handles % handles for plot axes 
% 
% datatrace % recorded data
% thval   % spike threshold
% plotparams = HPSearch2b_plotParamFromUI(handles);
% spidx = HPSearch2b_spikedetect()
% 
% tvec  % time vector
% wpst  % PSTH bin width (ms)       
% tpst  % PSTH time vector 
% vpst  % PSTH counts
% wisi  % ISIH bin width (ms) 
% tisi  % ISIH time vector 
% visi  % ISIH counts 
% nspiketotal;
% nspikelimit = 1000;
% rasterindex;
% rasterlimit = analysis.Raster;      % how many reps are shown
% 
%------------------------------------------------------------------------

% precalculate spike info
tspike = tvec(spidx); % spike timings
nspike = sum(spidx);  % spike number 

% if collected too many spikes, then erace histograms
nspiketotal = nspiketotal + nspike;
if nspiketotal > nspikelimit
    vpst = zeros(1, length(tpst) ); 
    visi = zeros(1, length(tisi) ); 
    nspiketotal = 0;
end

% if Clear Plot button is pressed, 
% then clear rester, PSTH and ISIH counting 
if read_ui_val(handles.buttonClearPlot);
    rasterindex = 0;
    vpst = zeros(1, length(tpst) ); 
    visi = zeros(1, length(tisi) ); 
    nspiketotal = 0;
    % reset the clear button # this is not needed because I dont disable the button
%     enable_ui(handles.buttonClearPlot);
%     update_ui_val(handles.buttonClearPlot, 0);
end

% Y limits for response and upclose plots [mV]
if plotparams.YAuto % auto setting (according to thval)
    yl = 2*abs(thval)*1000;
else % manual setting
    yl = plotparams.Yaxis * plotparams.Scale*1000; 
end

%% --- response 
if plotparams.plotResp
    % plot threshold 
    plot( handles.axesResp, [tvec(1) tvec(end)], [thval*1000 thval*1000], 'g');
    set( handles.axesResp, 'NextPlot', 'add' ); % = hold on
    tvec2 = linspace( 0, ( length( datatrace )-1 )./inFs*1000, length( datatrace )) + tvec( 1 ); % new time vector in case datatrace is longer than tvec
    % plot responses
    plot( handles.axesResp, tvec2, datatrace*1000, 'b'); 
    % plot spike timing
    plot( handles.axesResp, tspike, datatrace(spidx)*1000, 'mo');
    set( handles.axesResp, 'NextPlot', 'replace' ); % = hold off 
    % set x limit
    set( handles.axesResp, 'xlim', [0 tdt.AcqDuration]);
    % set Y limit
    if yl>0
        set( handles.axesResp, 'ylim', [ -yl yl ]);
    else 
        set( handles.axesResp, 'YlimMode', 'auto' );
    end

end 

%% --- upclose response  
if plotparams.plotUpclose
    % define window size
    if plotparams.minfreq > 1000
        upwindow = [-1, 1.5];
    elseif plotparams.maxfreq < 100
        upwindow = [-10, 15];
    else 
        a = 0.1 * round( 20000 / (plotparams.minfreq+plotparams.maxfreq) );
        if a < 1
            a = 1;
        elseif a > 10
            a = 10;
        end
        upwindow = [-1*a, 1.5*a]; 
    end

    % plot threshold
    plot( handles.axesUpclose, upwindow, [thval*1000 thval*1000], 'g'); 
    set( handles.axesUpclose, 'NextPlot', 'add' ); % = hold on
    % plot responses
    for j=1:nspike
        if( length( datatrace ) < length( tvec )),
            % use this in case less data than expected got returned
            plot( handles.axesUpclose, tvec(1:length( datatrace ))-tspike(j),datatrace*1000, 'b');
        else
            plot( handles.axesUpclose, tvec-tspike(j),datatrace*1000, 'b');
        end
    end
    set( handles.axesUpclose, 'NextPlot', 'replace' ); % = hold off 
    % set X limit
    set( handles.axesUpclose, 'xlim', upwindow );
    % set Y limit
    if yl>0 
        set( handles.axesUpclose, 'ylim', [ -yl yl ]);
    else
        set( handles.axesUpclose, 'YlimMode', 'auto' );
    end

end

%% --- raster
if plotparams.plotRaster
    % if reached to limit, then erase
    if(rasterindex == rasterlimit) 
        rasterindex = 0;
        cla(handles.axesRaster);
    end
    % plot raster
	set( handles.axesRaster, 'NextPlot', 'add' ); % = hold on 
    temp = rasterindex*ones(length(tspike));
    plot( handles.axesRaster, tspike, temp, 'b.') %% SLOW
    set( handles.axesRaster, 'NextPlot', 'replace' ); % = hold off 
    % set x and y limits
    set( handles.axesRaster, 'xlim', [ 0 tdt.AcqDuration ]);
    set( handles.axesRaster, 'ylim', [ 0 rasterlimit ]);
    % advance the raster counter
    rasterindex = rasterindex+1;
end

%% --- PSTH 
if plotparams.plotPSTH
    % calculate PSTH
    vpst = vpst + hist(tspike,tpst);
    set( handles.axesPSTH, 'NextPlot', 'replace' ); % = hold off
    % plot PSTH
    bar( handles.axesPSTH, tpst, vpst, 1)
    % set x limit
    set( handles.axesPSTH, 'xlim', [0 tdt.AcqDuration]);
end

%% --- ISIH 
if plotparams.plotISIH 
    % calculate ISIH
    if nspike>=2 
        cisi= tspike(2:end) - tspike(1:end-1);
        visi = visi + hist(cisi,tisi);
    end
    set( handles.axesISIH, 'NextPlot', 'replace' ); % = hold off 
    % plot ISIH
    bar( handles.axesISIH, tisi, visi, 1)
    % set x limit
    set( handles.axesISIH, 'xlim', [0 3]);
end
    
