%--------------------------------------------------------------------------
% HeadphoneCal2_Run_mainloop.m
%--------------------------------------------------------------------------
%
% main loop for headphone calibration
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad Shanbhag & Go Ashida
% sshanbha@aecom.yu.edu
% ashida@umd.edu
%--------------------------------------------------------------------------
% Original Version Written (MicrophoneCal_RunCalibration): 2008-2010 by SJS
% Upgraded Version Written (MicrophoneCal2_Run_mainloop): 2011-2012 by GA
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synthesize the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synthesize sine wave (monaural)
[Stmp, stimspec.RMS, stimspec.phi] = ...
    syn_calibrationtone(cal.Duration, iodev.Fs, freq, 0, 'L');
S(PLAYED,:) = Stmp(1,:); % this is sine wave
S(SILENT,:) = Stmp(2,:); % this is zero vector    
S = cal.DAlevel * S;
% apply the sin^2 amplitude envelope 
S = sin2array(S, cal.Ramp, iodev.Fs);

% plot the stim array
stimvecP = 0 * tvec; % reset to zero
stimvecP(delay_bin+1 : delay_bin+duration_bin) = S(PLAYED, :); % copy stim data
axes(axesStimP);
plot(tvec, stimvecP, Pcolor);
% plot the 'silent' array
stimvecS = 0 * tvec; % reset to zero
stimvecS(delay_bin+1 : delay_bin+duration_bin) = S(SILENT, :); % copy stim data
axes(axesStimS);
plot(tvec, stimvecS, Scolor);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure out the attenuation values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch cal.AttenType
    case 'VARIED' % go to loop below to fing the proper attenuation value
        RETRY = 1;

    case 'FIXED'
    % no need to test attenuation but do need to set the attenuators
        config.setattenFunc(PA5P, Patten);    
        config.setattenFunc(PA5S, Satten);    
        update_ui_str(editAttenP, Patten);
        update_ui_str(editAttenS, Satten);
        RETRY = 0;
end

%loop while figuring out the attenuator value.
while RETRY 
    % show info to user
    update_ui_str(handles.editRepVal, 'setting PA5');
    % set the attenuators
    config.setattenFunc(PA5P, Patten);
    config.setattenFunc(PA5S, Satten);
    update_ui_str(editAttenP, Patten);
    update_ui_str(editAttenS, Satten);
    % play the sound;
    [resp, rate] = config.ioFunc(iodev, S, acqpts);
    % plot the response
    axes(axesRespP);
    plot(tvec, resp{PLAYED}, Pcolor);
    axes(axesRespS);
    plot(tvec, resp{SILENT}, Scolor);
    % determine the magnitude and phase of the response
    [pmag, pphi] = fitsinvec(resp{PLAYED}(start_bin:end_bin), 1, iodev.Fs, freq);
    % adjust for the gain of the preamp and apply correction factors for RMS and microphone calibration
    pmag = cal.RMSsin * pmag / (cal.MicGain(PLAYED) * pmagadjval(freq_index));
    % compute dB SPL
    pmagdB = dbspl(cal.VtoPa(PLAYED) * pmag);
    % show values
    update_ui_str(editValP, sprintf('%.4f', 1000*pmag));
    update_ui_str(editSPLP, sprintf('%.2f', pmagdB));

    % check to see if the channel amplitude is in bounds
    if pmagdB > cal.MaxLevel % if sound too loud
        Patten = Patten + cal.AttenStep; % then increase attenuation
        if Patten > MAX_ATTEN  % if at limit, set max attenuation
            Patten = MAX_ATTEN;
            str = 'Attenuation maxed out!';
            set(handles.textMessage, 'String', str);
            RETRY = 0;
            STOPFLAG = -1;
        end
    elseif pmagdB < cal.MinLevel % if sound too faint
        Patten = Patten - cal.AttenStep; % then decrease attenuation
        if Patten <= 0
            Patten = 0;
            str = 'Attenuator at minimum level!';
            set(handles.textMessage, 'String', str);
            RETRY = 0;
            STOPFLAG = -2;
        end
    else % sound level is in the range
        RETRY = 0;
    end
 
    % check if user pressed ABORT button 
    if read_ui_val(handles.buttonAbort) == 1
        str = 'ABORT button pressed';
        break;
    end
    
end % of RETRY loop

% store the attenuator setting to copute max attainable SPL at this freq
caldata.atten(PLAYED, freq_index) = Patten;

% pause 
pause(cal.ISI/1000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calibration at the specified dBSPL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% now, collect the data for frequency FREQ
for rep = 1:cal.Reps
    % show rep number to user
    update_ui_str(handles.editRepVal, [ num2str(rep) ' / ' num2str(cal.Reps) ]);
    % play the sound;
    [resp, rate] = config.ioFunc(iodev, S, acqpts); 
    % plot the response
    axes(axesRespP);
    plot(tvec, resp{PLAYED}, Pcolor);
    axes(axesRespS);
    plot(tvec, resp{SILENT}, Scolor);
    % determine the magnitude and phase of the response/leak
    [pmag, pphi] = fitsinvec(resp{PLAYED}(start_bin:end_bin), 1, iodev.Fs, freq);
    [smag, sphi] = fitsinvec(resp{SILENT}(start_bin:end_bin), 1, iodev.Fs, freq);
    [pdistmag, pdistphi] = fitsinvec(resp{PLAYED}(start_bin:end_bin), 1, iodev.Fs, 2*freq);    
    [sdistmag, sdistphi] = fitsinvec(resp{SILENT}(start_bin:end_bin), 1, iodev.Fs, 2*freq);                
    % compute 2nd harmonic distortion ratio
    tmpdists{PLAYED}(freq_index, rep) = pdistmag / pmag;
    tmpleakdists{SILENT}(freq_index, rep) = sdistmag / smag;
    tmpdistphis{PLAYED}(freq_index, rep) = pdistphi - pphiadjval(freq_index);
    tmpleakdistphis{SILENT}(freq_index, rep) = sdistphi - sphiadjval(freq_index);
    % adjust for the gain of the preamp and convert to RMS
    pmag = cal.RMSsin * pmag / ( pmagadjval(freq_index) * cal.MicGain(PLAYED) );
    smag = cal.RMSsin * smag / ( smagadjval(freq_index) * cal.MicGain(SILENT) );
    % store the data in arrays
    tmprawmags{PLAYED}(freq_index, rep) = dbspl( cal.VtoPa(PLAYED) * pmag );
    tmpleakmags{SILENT}(freq_index, rep) = dbspl( cal.VtoPa(SILENT) * smag );
    tmpphis{PLAYED}(freq_index, rep) = pphi - pphiadjval(freq_index);
    tmpleakphis{SILENT}(freq_index, rep) = sphi - sphiadjval(freq_index);
    % show calculated values
    update_ui_str(editValP, sprintf('%.4f', 1000*pmag));
    update_ui_str(editSPLP, sprintf('%.2f', dbspl(cal.VtoPa(PLAYED)*pmag)));
    update_ui_str(editValS, sprintf('%.4f', 1000*smag));
    update_ui_str(editSPLS, sprintf('%.2f', dbspl(cal.VtoPa(SILENT)*smag)));
    % adjust mags using atten
    tmpmaxmags{PLAYED}(freq_index, rep) = ...
    tmprawmags{PLAYED}(freq_index, rep) + caldata.atten(PLAYED, freq_index);
    % store the raw response data
    rawdata.resp{freq_index, rep} = cell2mat(resp');
    % check if user pressed ABORT button 
    if read_ui_val(handles.buttonAbort) == 1
        str = 'ABORT button pressed';
        break;
    end
    % pause
    pause(cal.ISI/1000);
end
