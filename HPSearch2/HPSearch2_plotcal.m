function HPSearch2_plotcal(flagL, dataL, flagR, dataR)
%------------------------------------------------------------------------
% HPSearch2_plotcal.m
%------------------------------------------------------------------------
%  for plotting calibration data
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 20 October, 2011 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

figure;

if flagL
    %----- mag
    subplot(4,2,1);
    hmagL = gca;
    title('Calibrtion data L');
    hold off; plot(dataL.Freqs, dataL.mag, '.-g'); hold on;
    ylabel('Max Intensity (dB SPL)');
    xlim([dataL.Freqs(1) dataL.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    %----- maginv
    subplot(4,2,3);
    hinvL = gca;
    hold off; plot(dataL.Freqs, dataL.maginv, '.-g'); hold on;
    ylabel('Inverse Filter'); 
    xlim([dataL.Freqs(1) dataL.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    %----- phase
    subplot(4,2,5);
    hphL = gca;
    hold off; plot(dataL.Freqs, unwrap(dataL.phase), '.-g'); hold on;
    ylabel('Phase (deg)');
    xlim([dataL.Freqs(1) dataL.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    hold off;
    %----- phase (us)
    subplot(4,2,7);
    hpuL = gca;
    hold off; plot(dataL.Freqs, dataL.phase_us, '.-g'); hold on;
    ylabel('Phase (in us)');
    xlim([dataL.Freqs(1) dataL.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    hold off;
end

if flagR
    %----- mag
    subplot(4,2,2);
    hmagR = gca;
    title('Calibrtion data R');
    hold off; plot(dataR.Freqs, dataR.mag, '.-r'); hold on;
    ylabel('Max Intensity (dB SPL)');
    xlim([dataR.Freqs(1) dataR.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    %----- maginv
    subplot(4,2,4);
    hinvR = gca;
    hold off; plot(dataR.Freqs, dataR.maginv, '.-r'); hold on;
    ylabel('Inverse Filter'); 
    xlim([dataR.Freqs(1) dataR.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    %----- phase
    subplot(4,2,6);
    hphR = gca;
    hold off; plot(dataR.Freqs, unwrap(dataR.phase), '.-r'); hold on;
    ylabel('Phase (deg)');
    xlim([dataR.Freqs(1) dataR.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    hold off;
    %----- phase (us)
    subplot(4,2,8);
    hpuR = gca;
    hold off; plot(dataR.Freqs, dataR.phase_us, '.-r'); hold on;
    ylabel('Phase (in us)');
    xlim([dataR.Freqs(1) dataR.Freqs(end)]);
    set(gca, 'XGrid', 'on'); set(gca, 'YGrid', 'on');
    hold off;
end

if flagL && flagR
    ymag1 = min([get(hmagL,'YLim'), get(hmagR,'YLim')]);
    ymag2 = max([get(hmagL,'YLim'), get(hmagR,'YLim')]);
    set(hmagL, 'YLim', [ymag1, ymag2]);
    set(hmagR, 'YLim', [ymag1, ymag2]);

    yinv1 = min([get(hinvL,'YLim'), get(hinvR,'YLim')]);
    yinv2 = max([get(hinvL,'YLim'), get(hinvR,'YLim')]);
    set(hinvL, 'YLim', [yinv1, yinv2]);
    set(hinvR, 'YLim', [yinv1, yinv2]);

    yph1 = min([get(hphL,'YLim'), get(hphR,'YLim')]);
    yph2 = max([get(hphL,'YLim'), get(hphR,'YLim')]);
    set(hphL, 'YLim', [yph1, yph2]);
    set(hphR, 'YLim', [yph1, yph2]);

    ypu1 = min([get(hpuL,'YLim'), get(hpuR,'YLim')]);
    ypu2 = max([get(hpuL,'YLim'), get(hpuR,'YLim')]);
    set(hpuL, 'YLim', [ypu1, ypu2]);
    set(hpuR, 'YLim', [ypu1, ypu2]);

end
