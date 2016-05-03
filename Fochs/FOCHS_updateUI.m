function FOCHS_updateUI(handles,str)
%------------------------------------------------------------------------
% FOCHS_updateUI.m
%------------------------------------------------------------------------
%
% Updates UI components of FOCHS 
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida and Sharad Shanbhag
%   ashida@umd.edu
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Based on HPSearch2_updateUI: Oct 2011 (GA)
% Four-channel Input Version (FOCHS_updateUI): 2012 (GA)
% Optogen mods: 2016 by SJS
%------------------------------------------------------------------------

str = upper(str);

switch str

	% optical parameters
	case 'OPTICAL'
		update_ui_val(handles.checkOpto, handles.h2.optical.Enable);
		update_ui_str(handles.editOptoAmp, handles.h2.optical.Amp);
		update_ui_str(handles.editOptoDur, handles.h2.optical.Dur);
		update_ui_str(handles.editOptoDelay, handles.h2.optical.Delay);
		update_ui_str(handles.editOptoChan, handles.h2.optical.Channel);
		% enable/disable UI according to state of checkOpto (Enable)
		if handles.h2.optical.Enable
			update_ui_str(handles.checkOpto, 'on');
			set(handles.checkOpto, 'ForegroundColor', 'r');
			enable_ui(handles.editOptoAmp);
			enable_ui(handles.editOptoDur);
			enable_ui(handles.editOptoDelay);
			enable_ui(handles.editOptoChan);
		else
			update_ui_str(handles.checkOpto, 'off');
			set(handles.checkOpto, 'ForegroundColor', 'k');
			inactivate_ui(handles.editOptoAmp);
			inactivate_ui(handles.editOptoDur);
			inactivate_ui(handles.editOptoDelay);
			inactivate_ui(handles.editOptoChan);
		end
		return;
		
	% animal parameters
	case 'ANIMAL'
		update_ui_str(handles.editDate, handles.h2.animal.Date);
		update_ui_str(handles.editAnimal, handles.h2.animal.Animal);
		update_ui_str(handles.editUnit, handles.h2.animal.Unit);
		update_ui_str(handles.editRec, handles.h2.animal.Rec);
		update_ui_str(handles.editPen, handles.h2.animal.Pen);
		update_ui_str(handles.editAP, handles.h2.animal.AP);
		update_ui_str(handles.editML, handles.h2.animal.ML);
		update_ui_str(handles.editDepth, handles.h2.animal.Depth);
		return;

	% search parameters and sliders
	case 'SEARCH'
		FOCHS_updateUI(handles,'SEARCH:ATTEN');
		FOCHS_updateUI(handles,'SEARCH:FREQ');
		return;

	case 'SEARCH:ATTEN'
		update_ui_val(handles.checkLeftON, handles.h2.search.LeftON);
		update_ui_val(handles.checkRightON, handles.h2.search.RightON);
		update_ui_str(handles.editITD, handles.h2.search.ITD);
		update_ui_val(handles.sliderITD, handles.h2.search.ITD);
		update_ui_str(handles.editILD, handles.h2.search.ILD);
		update_ui_val(handles.sliderILD, handles.h2.search.ILD);
		update_ui_str(handles.editLatt, handles.h2.search.Latt);
		update_ui_val(handles.sliderLatt, handles.h2.search.Latt);
		update_ui_str(handles.editRatt, handles.h2.search.Ratt);
		update_ui_val(handles.sliderRatt, handles.h2.search.Ratt);
		update_ui_str(handles.editABI, handles.h2.search.ABI);
		update_ui_val(handles.sliderABI, handles.h2.search.ABI);
		% enable/disable UI according to on/off settings
		if handles.h2.search.LeftON && handles.h2.search.RightON % both ON
			inactivate_ui(handles.sliderLatt); inactivate_ui(handles.editLatt);
			inactivate_ui(handles.sliderRatt); inactivate_ui(handles.editRatt);
			enable_ui(handles.sliderABI);      enable_ui(handles.editABI);
			enable_ui(handles.sliderILD);      enable_ui(handles.editILD);
			enable_ui(handles.sliderITD);      enable_ui(handles.editITD);
			enable_ui(handles.sliderBC);       enable_ui(handles.editBC);
		elseif handles.h2.search.LeftON && ~handles.h2.search.RightON % LEFT ON
			inactivate_ui(handles.sliderLatt); inactivate_ui(handles.editLatt);  
			disable_ui(handles.sliderRatt);    disable_ui(handles.editRatt);
			enable_ui(handles.sliderABI);      enable_ui(handles.editABI);
			disable_ui(handles.sliderILD);     disable_ui(handles.editILD);
			disable_ui(handles.sliderITD);     disable_ui(handles.editITD);
			disable_ui(handles.sliderBC);      disable_ui(handles.editBC);
		elseif ~handles.h2.search.LeftON && handles.h2.search.RightON % RIGHT ON
			disable_ui(handles.sliderLatt);    disable_ui(handles.editLatt);
			inactivate_ui(handles.sliderRatt); inactivate_ui(handles.editRatt);
			enable_ui(handles.sliderABI);      enable_ui(handles.editABI);
			disable_ui(handles.sliderILD);     disable_ui(handles.editILD);
			disable_ui(handles.sliderITD);     disable_ui(handles.editITD);
			disable_ui(handles.sliderBC);      disable_ui(handles.editBC);
		else % both OFF 
			disable_ui(handles.sliderLatt);    disable_ui(handles.editLatt);
			disable_ui(handles.sliderRatt);    disable_ui(handles.editRatt);
			disable_ui(handles.sliderABI);     disable_ui(handles.editABI);
			disable_ui(handles.sliderILD);     disable_ui(handles.editILD);
			disable_ui(handles.sliderITD);     disable_ui(handles.editITD);
			disable_ui(handles.sliderBC);      disable_ui(handles.editBC);
		end
		return;

    case 'SEARCH:FREQ'
		update_ui_str(handles.editBC, handles.h2.search.BC);
		update_ui_val(handles.sliderBC, handles.h2.search.BC);
		update_ui_str(handles.editFreq, handles.h2.search.Freq);
		update_ui_val(handles.sliderFreq, handles.h2.search.Freq);
		update_ui_str(handles.editBW, handles.h2.search.BW);
		update_ui_val(handles.sliderBW, handles.h2.search.BW);
		update_ui_str(handles.editFmax, handles.h2.search.Fmax);
		update_ui_str(handles.editFmin, handles.h2.search.Fmin);
		update_ui_str(handles.editsAMp, handles.h2.search.sAMp);
		update_ui_val(handles.slidersAMp, handles.h2.search.sAMp);
		update_ui_str(handles.editsAMf, handles.h2.search.sAMf);
		update_ui_val(handles.slidersAMf, handles.h2.search.sAMf);
		% enable/disable UI according to stimulus type settings
		str_stimtype = upper(handles.h2.search.stimtype);
		switch str_stimtype
		case 'NOISE'
			enable_ui(handles.sliderBW);    enable_ui(handles.editBW);
			enable_ui(handles.editFmax);    enable_ui(handles.editFmin);
			disable_ui(handles.slidersAMp); disable_ui(handles.editsAMp);
			disable_ui(handles.slidersAMf); disable_ui(handles.editsAMf);
		case 'TONE'
			disable_ui(handles.sliderBW);   disable_ui(handles.editBW);
			disable_ui(handles.editFmax);   disable_ui(handles.editFmin);
			disable_ui(handles.slidersAMp); disable_ui(handles.editsAMp);
			disable_ui(handles.slidersAMf); disable_ui(handles.editsAMf);
		case 'SAM'
			enable_ui(handles.sliderBW);    enable_ui(handles.editBW);
			enable_ui(handles.editFmax);    enable_ui(handles.editFmin);
			enable_ui(handles.slidersAMp);  enable_ui(handles.editsAMp);
			enable_ui(handles.slidersAMf);  enable_ui(handles.editsAMf);        
		end
	return;

% stimulus settings
    case 'STIMULUS'
        update_ui_str(handles.editISI, handles.h2.stimulus.ISI);
        update_ui_str(handles.editDuration, handles.h2.stimulus.Duration);
        update_ui_str(handles.editDelay, handles.h2.stimulus.Delay);
        update_ui_str(handles.editRamp, handles.h2.stimulus.Ramp);
        update_ui_val(handles.checkRadVary, handles.h2.stimulus.RadVary);
        update_ui_val(handles.checkFrozenStim, handles.h2.stimulus.Frozen);
        return;

% TDT settings
    case 'TDT'
        update_ui_str(handles.editAcqDuration, handles.h2.tdt.AcqDuration);
        update_ui_str(handles.editSweepPeriod, handles.h2.tdt.SweepPeriod);
        update_ui_str(handles.editTTLPulseDur, handles.h2.tdt.TTLPulseDur);
        update_ui_str(handles.editCircuitGain, handles.h2.tdt.CircuitGain);
        update_ui_str(handles.editHPFreq, handles.h2.tdt.HPFreq);
        update_ui_str(handles.editLPFreq, handles.h2.tdt.LPFreq);
        return;

% I/O channel settings
    case 'CHANNELS'
        update_ui_str(handles.editOutputL, handles.h2.channels.OutputChannelL);
        update_ui_str(handles.editOutputR, handles.h2.channels.OutputChannelR);
        update_ui_str(handles.editInput1, handles.h2.channels.InputChannel1);
        update_ui_str(handles.editInput2, handles.h2.channels.InputChannel2);
        update_ui_str(handles.editInput3, handles.h2.channels.InputChannel3);
        update_ui_str(handles.editInput4, handles.h2.channels.InputChannel4);
        return;

% spike analysis settings
    case 'ANALYSIS'
        update_ui_str(handles.editStartTime, handles.h2.analysis.StartTime);
        update_ui_str(handles.editEndTime, handles.h2.analysis.EndTime);
        return;

	% curve parameter settings
	case 'CURVE'
		% stimulus strings and checkboxes
		update_ui_str(handles.editCurveReps, handles.h2.paramCurrent.Reps);
		update_ui_str(handles.editCurveITD, handles.h2.paramCurrent.ITDstring);
		update_ui_str(handles.editCurveILD, handles.h2.paramCurrent.ILDstring);
		update_ui_str(handles.editCurveABI, handles.h2.paramCurrent.ABIstring);
		update_ui_str(handles.editCurveFreq, handles.h2.paramCurrent.Freqstring);
		update_ui_str(handles.editCurveBC, handles.h2.paramCurrent.BCstring);
		update_ui_str(handles.editCurvesAMp, handles.h2.paramCurrent.sAMpstring);
		update_ui_str(handles.editCurvesAMf, handles.h2.paramCurrent.sAMfstring);
		update_ui_val(handles.checkCurveSpont, handles.h2.curve.Spont);
		update_ui_val(handles.checkCurveTemp, handles.h2.curve.Temp);
		update_ui_val(handles.checkCurveSaveStim, handles.h2.curve.SaveStim);
		% radio buttons for Curve Type
		str_curvetype = upper(handles.h2.paramCurrent.curvetype);
		switch str_curvetype
			case 'BF'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeBF);
			case 'ITD'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeITD);
			case 'ILD'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeILD);
			case 'ABI'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeABI);
			case 'BC'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeBC);
			case 'SAMP'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypesAMp);
			case 'SAMF'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypesAMf);
			case 'CF'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeCF);
			case 'CD'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypeCD);
			case 'PH'
				set(handles.radioCurveType, 'SelectedObject', handles.radioCurveTypePH);
		end
		% radio buttons for Stim Type
		str_stimtype = upper(handles.h2.curve.stimtype);
		switch str_stimtype
			case 'NOISE'
				set(handles.radioCurveStim, 'SelectedObject', handles.radioCurveStimNoise);  
			case 'TONE'
				set(handles.radioCurveStim, 'SelectedObject', handles.radioCurveStimTone); 
		end
		% radio buttons for Stim Side
		str_curveside = upper(handles.h2.curve.side);
		switch str_curveside
			case 'BOTH'
				set(handles.radioCurveSide, 'SelectedObject', handles.radioCurveSideBoth);                
			case 'LEFT'
				set(handles.radioCurveSide, 'SelectedObject', handles.radioCurveSideLeft);                
			case 'RIGHT'
				set(handles.radioCurveSide, 'SelectedObject', handles.radioCurveSideRight);                
		end
		return;

	% click parameter settings
	case 'CLICK'
		update_ui_str(handles.editClickSamples, handles.h2.click.Samples);
		update_ui_str(handles.editClickReps, handles.h2.click.Reps);
		update_ui_str(handles.editClickITD, handles.h2.click.ITDstring);
		update_ui_str(handles.editClickLatten, handles.h2.click.Latten);
		update_ui_str(handles.editClickRatten, handles.h2.click.Ratten);
		str_clicktype = upper(handles.h2.click.clicktype);
		switch str_clicktype
			case 'COND'
				set(handles.radioClickType, 'SelectedObject', handles.radioClickTypeCond);  
			case 'RARE'
				set(handles.radioClickType, 'SelectedObject', handles.radioClickTypeRare); 
		end
		str_clickside = upper(handles.h2.click.side);
		switch str_clickside
			case 'BOTH'
				set(handles.radioClickSide, 'SelectedObject', handles.radioClickSideBoth); 
			case 'LEFT'
				set(handles.radioClickSide, 'SelectedObject', handles.radioClickSideLeft); 
			case 'RIGHT'
				set(handles.radioClickSide, 'SelectedObject', handles.radioClickSideRight);  
		end
		return;

	% plot settings
	case 'PLOTS'
		update_ui_val(handles.checkPlotResp, handles.h2.plots.plotResp);
		update_ui_val(handles.checkPlotUpclose, handles.h2.plots.plotUpclose);
		update_ui_val(handles.checkShowCh1, handles.h2.plots.Ch1);
		update_ui_val(handles.checkShowCh2, handles.h2.plots.Ch2);
		update_ui_val(handles.checkShowCh3, handles.h2.plots.Ch3);
		update_ui_val(handles.checkShowCh4, handles.h2.plots.Ch4);
		return;
end

