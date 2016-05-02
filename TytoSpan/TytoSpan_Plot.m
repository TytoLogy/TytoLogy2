% TytoSpan_Plot.m
%------------------------------------------------------------------------
% 
% Script for plotting waveforms
% This script is called from TytoSpanGUI.m
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Original Version Written (TytoSpan_Plot): Oct 2013 by GA
%------------------------------------------------------------------------

acqd = handles.d.curvesettings.tdt.AcqDuration;
inFs = handles.d.curvesettings.Fs(1);
acqp = ms2samples(acqd, inFs);
tvec = 1000*(0:acqp-1)/inFs; % (ms)
zvec = zeros(size(tvec)); % zero vector as dummy data
nmax = handles.v.nstims;

% plot waveforms
for i=1:5;

    % index of the curve to show
    cidx = handles.v.TrN(i);

    % unfiltered waveform
    axes(handles.ploth(1,i)); 
    cla; zoom on; zoom out;
    if handles.f.loaded
        hold off;
        if (cidx>0) && (cidx<=nmax)
            datatrace = handles.d.curveresp{cidx}*1000;
            plot(tvec, datatrace,'b');
            if handles.f.threshold
                hold on; 
                % plot threshold
                plot([min(tvec) max(tvec)], [handles.v.thval*1000 handles.v.thval*1000], 'g'); 
                % plot peak points
                plot(tvec(handles.a.spike_idx{cidx}), ...
                    datatrace(handles.a.spike_idx{cidx}), 'mo')
            end
        else
            plot(tvec, zvec, 'r');
        end
    end

    % filtered waveform
    axes(handles.ploth(2,i)); 
    cla; zoom on; zoom out;
    if handles.f.filtered
        hold off;
        if (cidx>0) && (cidx<=nmax)
            datatrace = handles.d.filteresp{cidx}*1000;
            plot(tvec, datatrace, 'b');
            if handles.f.threshold
                hold on; 
                % plot threshold
                plot([min(tvec) max(tvec)], [handles.v.thval*1000 handles.v.thval*1000], 'g'); 
                % plot peak points
                plot(tvec(handles.a.spike_idx{cidx}), ...
                    datatrace(handles.a.spike_idx{cidx}), 'mo')
            end
        else
            plot(tvec, zvec, 'r');
        end
    end

    % upclose traces around detected spikes
    axes(handles.ploth(3,i));
    cla; zoom on; zoom out;
    if handles.f.threshold
        upwindow = [-1, 1.5]; 
        hold off; 
        if (cidx>0) && (cidx<=nmax)
            % plot threshold
            plot(upwindow, [handles.v.thval*1000 handles.v.thval*1000], 'g'); 
            hold on;
            % plot responses
            for j=1:handles.a.spike_counts(cidx)
                plot(tvec-handles.a.spike_times{cidx}(j), ...
                        handles.d.filteresp{cidx}*1000, 'b');
            end
        end
        hold off;
        xlim(upwindow);
    end 

end

% show waveform data
str = sprintf(' %s   %s\n', handles.v.loopvars{1}, handles.v.loopvars{2});
for i=1:5
    % index of the curve to show
    cidx = handles.v.TrN(i);
    % add string to show
    if (cidx>0) && (cidx<=nmax)
        str = sprintf('%s% 5.0f % 5.0f\n', str, ...
              handles.v.depvar1(cidx), handles.v.depvar2(cidx)); 
    else
        str = sprintf('%s xxxxx  xxxxx\n', str);
    end
end
set(handles.textTraces, 'String', str); % show text

% show threshold data
str = sprintf(' Rates\n');
for i=1:5
    % index of the curve to show
    cidx = handles.v.TrN(i);
    % add string to show
    if (cidx>0) && (cidx<=nmax) && handles.f.threshold
        a_rate = 1000 * handles.a.spike_counts(cidx) / (handles.v.End-handles.v.Start);
        str = sprintf('%s% 5.0f\n', str, a_rate); 
    else
        str = sprintf('%s xxxxx\n', str);
    end
end
set(handles.textRates, 'String', str); % show text

