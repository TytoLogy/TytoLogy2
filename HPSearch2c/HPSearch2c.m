function varargout = HPSearch2c(varargin)
% HPSEARCH2C M-file for HPSearch2c.fig
%
% Last Modified by GUIDE v2.5 18-Mar-2015 13:18:03

%------------------------------------------------------------------------
%  Go Ashida, Felix Dollack & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2): 2011-2012 by GA
% Improved Version Written (HPSearch2a): Aug 2012 by GA
% Improved Version Written (HPSearch2c): Nov 2012 by GA
% Call External Stim Added (HPSearch2c): Nov 2012 by GA&FD
%--------------------------------------------------------------------------
% ** Important Notes ** 
%  (Nov 2011, GA)
%   Parameters used in HPSearch2c are stored under the handles.h2 structure,
%   while parameters used in HPSearch are stored directly under handles 
%
%  (Feb 2012, GA)
%   This HPSearch2c.m file handles only GUI-related issues. 
%   Most parts of recording and other components are delegated to 
%   corresponding subroutines (see below for a list). 
% 
%  (Aug 2012, GA)
%   HPSearch2a is an improved version of HPSearch2. 
%   Some GUI related issues have been upgraded. 
% 
%  (Nov 2012, GA)
%   HPSearch2b is an improved version of HPSearch2a. 
%   FILD has been added. 
%
%  (Jan 2015, GA)
%   SAM tone has been added. 
%   Panel for calling external stimulus has been added. 
%--------------------------------------------------------------------------
% [ Major Subroutines ] 
% * HPSearch2c_Opening.m     : called from HPSearch2c_OpeningFcn
% * HPSearch2c_Closing.m     : called from CloseRequestFcn
% * HPSearch2c_TDTopen.m     : called from buttonTDTenable_Callback
% * HPSearch2c_TDTclose.m    : called from buttonTDTenable_Callback
%
% * HPSearch2c_Search.m      : called from buttonSearch_Callback
% * HPSearch2c_Curve.m       : called from buttonCurve_Callback
% * HPSearch2c_Click.m       : called from buttonClick_Callback
% 
% * HPSearch2c_init.m        : used for initializing parameters
% * HPSearch2c_config.m      : used for TDT hardware settings 
% * HPSearch2c_updateUI.m    : used for updating the GUI
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Initialization code automatically created by Matlab GUIDE ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %--------------------------------------------------------------------------
    % Begin initialization code - DO NOT EDIT 
    %--------------------------------------------------------------------------
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @HPSearch2c_OpeningFcn, ...
                       'gui_OutputFcn',  @HPSearch2c_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end

    %--------------------------------------------------------------------------
    % End initialization code - DO NOT EDIT
    %--------------------------------------------------------------------------
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before HPSearch2c is made visible. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function HPSearch2c_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.DEBUG = 1;  % 1:debug mode; 0:normal mode 
    guidata(hObject, handles);
    % show message
    str = '** HPSearch2c: opening function called';
    set(handles.textMessage, 'String', str);
    % if debug mode, enable 'Show Variable' button
    if(handles.DEBUG) 
        disp(str); 
        enable_ui(handles.buttonShowVal);
        set(handles.buttonShowVal, 'Visible', 'on');
    end
    % go to the opening function
    HPSearch2c_Opening;
end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function varargout = HPSearch2c_OutputFcn(hObject, eventdata, handles) 
    % show message 
    str = '** HPSearch2c: output function called'; 
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % set output
    varargout{1} = hObject;
end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Cleaning up before closing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

%% without module - editboxes and debug button
function HPSearch2c_CloseRequestFcn(hObject, eventdata, handles)
    % show message 
    str = '** HPSearch2c: closing function called';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % go to the closing function 
    HPSearch2c_Closing;
    delete( handles.h_plotwin ); % close plot window
    delete( hObject );
end
%--------------------------------------------------------------------------
function editAutoTh_Callback(hObject, eventdata, handles)
% This editbox is only for showing automatically determined threshold 
% User cannot edit this box.
end
%--------------------------------------------------------------------------
function editRate_Callback(hObject, eventdata, handles)
% This editbox is only for showing spike rates.
% User cannot edit this box.
end

%% Show Variable button (for debugging)
function buttonShowVal_Callback(hObject, eventdata, handles)
    varname = input('### Variable name? ','s'); 
    try
        eval([ 'tmp = ' varname ';']); 
        disp(tmp);
    catch
        e = lasterror;
        disp(['###### ' e.message]);
        disp(['###### ' e.identifier]);
    end
end

%% TDT module - popup
% menu for selecting TDT hardware
function popupTDT_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT hardware selection changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % read out the selected value
    tdtStrings = read_ui_str(hObject);  % list of strings
    selectedVal = read_ui_val(hObject); % selected item number
    selectedStr = upper(tdtStrings{selectedVal}); % selected item
    switch selectedStr 
        case 'NO_TDT'
            disp('No TDT hardware used')
            handles.WithoutTDT = 1; 
        case 'RX8_50K'
            disp('RX8 selected. Sampling rate: 50 kHz')
            handles.WithoutTDT = 0; 
        case 'RX6_50K'
            disp('RX6 selected. Sampling rate: 50 kHz')
            handles.WithoutTDT = 0; 
        case 'MEDUSA'
            disp('MEDUSA selected. Sampling rate: 50/25 kHz')
            handles.WithoutTDT = 0; 
    end
    % update handles.h2.config according to the selection of TDT
    handles.h2.config = HPSearch2c_config(selectedStr);
    handles.h2.config.TDTLOCKFILE = handles.TDTLOCKFILE;
	guidata(hObject, handles); 
end

%% TDT module - button
% Enabling (or disabling) TDT hardware
function buttonTDTenable_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT Enable/Disable button clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % define colors
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red
    INITCOLOR   = [0.0 0.0 0.5];  % Dark Blue
    ENABLECOLOR = [0.0 0.5 0.0];  % Dark Green	

    % get the state of the button
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
    if buttonState % User pressed button to enable TDT Circuits
        set(handles.buttonTDTenable, 'ForegroundColor', INITCOLOR);
        update_ui_str(hObject, 'initializing')

        % Attempt to open TDT hardware
        [ tmphandles, tmpflag ] = HPSearch2c_TDTopen(handles.h2.config);

        if tmpflag > 0  % TDT hardware is running 
            % copy handles structure if TDT is newly started or restarted
            if tmpflag ==1; 
                handles.indev = tmphandles.indev;
                handles.outdev = tmphandles.outdev;
                handles.zBUS  = tmphandles.zBUS;
                handles.PA5L  = tmphandles.PA5L;
                handles.PA5R  = tmphandles.PA5R;
                MAXATTEN = 120;
                handles.h2.config.setattenFunc(handles.PA5L, MAXATTEN);
                handles.h2.config.setattenFunc(handles.PA5R, MAXATTEN);
            end
            % update UI
            set(hObject, 'ForegroundColor', DISABLECOLOR);
            update_ui_str(hObject, 'TDT Disable')
            disable_ui(handles.popupTDT);
            enable_ui(handles.buttonSearch);
            enable_ui(handles.buttonCurve);
            enable_ui(handles.buttonClick);
            % enable the monitor button if the medusa is used
            switch upper(handles.h2.config.CONFIGNAME)
                case {'MEDUSA','NO_TDT'}
                enable_ui(handles.buttonMonitor);
                enable_ui(handles.editMonitorGain);
            end
        elseif tmpflag < 0  % faied to start TDT
            disp([mfilename ': failed to start TDT'])
            update_ui_val(hObject, 0);
            set(hObject, 'ForegroundColor', ENABLECOLOR);
            update_ui_str(hObject, 'TDT Enable');
        else % tmpflag==0, TDT is not initialized
            disp([mfilename ': TDT is not initialized'])
            update_ui_val(hObject, 0);
            set(hObject, 'ForegroundColor', ENABLECOLOR);
            update_ui_str(hObject, 'TDT Enable');
        end

    else % buttonState == 0: User pressed button to turn off TDT Circuits
        set(handles.buttonTDTenable, 'ForegroundColor', INITCOLOR);
        update_ui_str(hObject, 'disabling')

        [ tmphandles, tmpflag ] = HPSearch2c_TDTclose(handles.h2.config, ...
            handles.indev, handles.outdev, handles.zBUS, handles.PA5L, handles.PA5R);

        if tmpflag > 0  % TDT hardware has been successfully terminated
            % copy status infomation
            handles.indev.status = tmphandles.indev.status;
            handles.outdev.status = tmphandles.outdev.status;
            handles.zBUS.status = tmphandles.zBUS.status;
            handles.PA5L.status = tmphandles.PA5L.status;
            handles.PA5R.status = tmphandles.PA5R.status;
            % update UI
            set(hObject, 'ForegroundColor', ENABLECOLOR);
            update_ui_str(hObject, 'TDT Enable')
            enable_ui(handles.popupTDT);
            disable_ui(handles.buttonSearch);
            disable_ui(handles.buttonCurve);
            disable_ui(handles.buttonClick);
            % update the Monitor button
            update_ui_val(handles.buttonMonitor, 0);
            update_ui_str(handles.buttonMonitor, 'Monitor OFF')
            set(handles.buttonMonitor, 'ForegroundColor', DISABLECOLOR);
            disable_ui(handles.buttonMonitor);
            disable_ui(handles.editMonitorGain);

        else % tmpflag <= 0  % faied to stop TDT
            disp([mfilename ': failed to stop TDT...'])
            set(hObject, 'ForegroundColor', DISABLECOLOR);
            update_ui_str(hObject, 'TDT Disable')
        end

    end % end of "if buttonState"
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function buttonMonitor_Callback(hObject, eventdata, handles)
    % show message 
    str = '** Monitor button clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % define colors
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red
    ENABLECOLOR = [0.0 0.0 0.5];  % Dark Green	

    % get the state of the button
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
    if buttonState % User pressed button to start monitoring
        % updating UI
        set(hObject, 'ForegroundColor', ENABLECOLOR);
        update_ui_str(hObject, 'Monitor ON')

        % check hardware selection 
        switch upper(handles.h2.config.CONFIGNAME)
            case 'MEDUSA'
                % Turn on the monitor channel
                RPtrig(handles.indev, 1);
            case 'NO_TDT' % this is for debuging
                pause(0.5);
        end

    else % User pressed button to stop monitoring
        % updating UI
        set(hObject, 'ForegroundColor', DISABLECOLOR);
        update_ui_str(hObject, 'Monitor OFF')

        switch upper(handles.h2.config.CONFIGNAME)
            case 'MEDUSA'
                % Turn off the monitor channel
                RPtrig(handles.indev, 2);
            case 'NO_TDT' % this is for debuging
                pause(0.5);
        end
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editMonitorGain_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT hardware: monitor gain changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variables 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.MonitorGain)	% check limits
		handles.h2.tdt.MonitorGain = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.MonitorGain);
    end
end

%% SEARCH modules - button callback
%--------------------------------------------------------------------------
% When user clicks the SEARCH button, the value of the button is toggled; 
% If the button is "hi" (value == 1), the user wishes to start the run.
% If the button is "lo" (value == 0), the user wants to stop the run.  
% If start requested, also need to make sure the TDT is enabled. (SJS)
%--------------------------------------------------------------------------
function buttonSearch_Callback(hObject, eventdata, handles)
    % show message 
    str = '** SEARCH button clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % define colors
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red
    ENABLECOLOR = [0.0 0.5 0.0];  % Dark Green	

    % get the states of the button and TDTINIT 
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
	load(handles.h2.config.TDTLOCKFILE); % loading TDTINIT 
    %-----------------------------------------------------
    % buttonState=0 & TDTINIT=0 : (this should not happen: the button is disabled before TDT is initialized)
    % buttonState=1 & TDTINIT=0 : need to start TDT before starting stimulus
    % buttonState=0 & TDTINIT=1 : stop search stimulus
    % buttonState=1 & TDTINIT=1 : start search stimulus
    %-----------------------------------------------------

    % if user wants to start, check if TDT hardware has been initialized
    if buttonState && ~TDTINIT
        disp([mfilename ': TDT Hardware is not initialized!! Cancelling search...']);
        % updating UI
        update_ui_val(hObject, 0);
        update_ui_str(hObject, 'Search');
        set(hObject, 'ForegroundColor', ENABLECOLOR);

    % if buttonState is 0 and TDT hardware is running, then stop stimulus
    % Note: loop in HPSearch2c_Search.m finishes when "read_ui_val(hObject)=0"
    elseif ~buttonState && TDTINIT
        disp('Ending search stimuli...');
        % updating UI and enabling other buttons
        update_ui_str(hObject, 'Search')
        set(hObject, 'ForegroundColor', ENABLECOLOR);
        HPSearch2c_enableUIs(handles,'ENABLE');
    % if buttonState is 1 and TDT is running, then start stimulus
    % stimulus will remain ON, while "read_ui_val(hObject)=1"
    else 
        disp('Starting search stimuli...')
        % updating UI and disabling other buttons
        update_ui_str(hObject, 'Stop');
        set(hObject, 'ForegroundColor', DISABLECOLOR);
        HPSearch2c_enableUIs(handles,'DISABLE');
        disable_ui(handles.buttonAbort);
        disable_ui(handles.buttonPause);
        % go to main part of Search
        guidata(hObject, handles);
        HPSearch2c_Search; 
    end 
    guidata(hObject,handles); 
end

%% Curves module - button callback
function buttonCurve_Callback(hObject, eventdata, handles)
    % show message 
    str = '** CURVE button clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode

    % updating UI and disabling other buttons
    HPSearch2c_enableUIs(handles,'DISABLE');
    disable_ui(handles.buttonSearch);

    % set the flag to zero
    CurveSuccessFlag = 0; % success=1, unfinished=0, aborted=-1, failed=-2

    % get the states of the button and TDTINIT 
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
	load(handles.h2.config.TDTLOCKFILE); % loading TDTINIT 

    % Note: Since the button is supposed to be disabled while stimulus is ON, 
    %       it is unlikely that buttonState=0 can be detected. 
    if ~buttonState 
        disp('Curve button was hit even though it should have been disabled');
        disp('Something seems to be wrong...');
        return;
    end

    % if user wants to start, check if TDT hardware has been initialized
	if ~TDTINIT
        warndlg(['TDT Hardware is not initialized!!'], 'TDT error');
        CurveSuccessFlag = -2; % failed 
    end

	% user wants to run curve, TDT hardware is running, so all is well
	if CurveSuccessFlag ==0  
		disp('Starting curve...');
        % go to main part of Curve
        update_ui_str(hObject, 'Running');
        guidata(hObject, handles);
        HPSearch2c_Curve; 
        update_ui_str(hObject, 'Run Curve');

        % if succeeded then advance #Rec
        if CurveSuccessFlag > 0 
            tmp = str2double(handles.h2.animal.Rec); 
            if ~isnan(tmp)
                handles.h2.animal.Rec = num2str(round(tmp+1));
            end
            % show outputfile in command window
            display( curvefile );
        end
    end

    % updating animals info
    handles.h2.animal.Date = TytoLogy2_datetime('date');
    handles.h2.animal.Time = TytoLogy2_datetime('time');
    HPSearch2c_updateUI(handles,'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    HPSearch2c_enableUIs(handles,'ENABLE');

    % save handles structure 
    guidata(hObject, handles);
end

%% Clicks module - button callback
function buttonClick_Callback(hObject, eventdata, handles)
    % show message 
    str = '** CLICK button clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode

    % updating UI and disabling other buttons
    HPSearch2c_enableUIs(handles,'DISABLE');
    disable_ui(handles.buttonSearch);

    % set the flag to zero
    ClickSuccessFlag = 0; % success=1, unfinished=0, aborted=-1, failed=-2

    % get the states of the button and TDTINIT 
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
	load(handles.h2.config.TDTLOCKFILE); % loading TDTINIT 

    % Note: Since the button will be disabled while stimulus is ON, 
    %       it is unlikely that buttonState=0 can be detected. 
    if ~buttonState 
        disp('Click button was hit even though it should have been disabled');
        disp('Something seems to be wrong...');
        return;
    end

    % if user wants to start, check if TDT hardware has been initialized
	if ~TDTINIT
        disp([mfilename ': TDT Hardware is not initialized!! Cancelling curve...']);
        ClickSuccessFlag = -2; % failed 
    end

	% user wants to run clicks, TDT hardware is running, so all is well
	if ClickSuccessFlag == 0
		disp('Starting click...');
        % go to main part of Curve
        update_ui_str(hObject, 'Running');
        guidata(hObject, handles);
        HPSearch2c_Click; 
        update_ui_str(hObject, 'Run Clicks');

        % if succeeded then advance #Rec
        if ClickSuccessFlag > 0 
            tmp = str2double(handles.h2.animal.Rec); 
            if ~isnan(tmp)
                handles.h2.animal.Rec = num2str(round(tmp+1));
            end
            % show outputfile again in command window
            display( clickfile );
        end
    end

    % updating animals info
    handles.h2.animal.Date = TytoLogy2_datetime('date');
    handles.h2.animal.Time = TytoLogy2_datetime('time');
    HPSearch2c_updateUI(handles,'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    HPSearch2c_enableUIs(handles,'ENABLE');

    % save handles structure 
    guidata(hObject, handles);
end

%% Control module - buttons
function buttonAbort_Callback(hObject, eventdata, handles)
    % show message 
    str = 'ABORTING!';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % disable ui --- should be re-enabled in other (Curve or Click) routines 
    disable_ui(hObject); 
    guidata(hObject, handles);	
end
%--------------------------------------------------------------------------
function buttonPause_Callback(hObject, eventdata, handles)
    % show message 
    str = 'PAUSE/RESUME clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get the state of the button 
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
    if buttonState % pause is ON
        update_ui_str(hObject, 'Resume')
    else % pause is OFF
        update_ui_str(hObject, 'Pause')
    end
    guidata(hObject, handles);	
end
%--------------------------------------------------------------------------
% Control module - Call Plot button (for viewing recorded data)
function buttonCallPlot_Callback(hObject, eventdata, handles)
    % show message 
    str = '** Call Plot button pressed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % call plotting scripts
    TytoView_simpleView; 
end

%% SEARCH module - checkboxes
function checkLeftON_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Left ON clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check cal and enable left output
    handles.h2.search.LeftON = read_ui_val(hObject);
    if handles.h2.search.LeftON 
        if ~handles.h2.calinfo.loadedL
            disp('Calibration file for LEFT should be loaded!!')
            update_ui_val(hObject, 0); % reset checkbox state
            handles.h2.search.LeftON = 0;
            update_ui_val(handles.checkLeftON, handles.h2.search.LeftON);
            guidata(hObject,handles);
            return;
        else
            disp('Left channel ON');
        end
    end 
    guidata(hObject, handles); 
    HPSearch2c_updateUI(handles,'SEARCH:ATTEN');
end
%--------------------------------------------------------------------------
function checkRightON_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Right ON clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check cal and enable left output
    handles.h2.search.RightON = read_ui_val(hObject);
    if handles.h2.search.RightON 
        if ~handles.h2.calinfo.loadedR
            disp('Calibration file for RIGHT should be loaded!!')
            update_ui_val(hObject, 0); % reset checkbox state
            handles.h2.search.RightON = 0;
            update_ui_val(handles.checkRightON, handles.h2.search.RightON);
            guidata(hObject,handles);
            return;
        else  
            disp('Right channel ON');
        end
    end 
    guidata(hObject, handles); 
    HPSearch2c_updateUI(handles,'SEARCH:ATTEN');
end

%% SEARCH module - slider
function sliderLatt_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Latt slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.Latt = ...
        slider_update(handles.sliderLatt, handles.editLatt);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderRatt_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Ratt slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.Ratt = ...
        slider_update(handles.sliderRatt, handles.editRatt);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderILD_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: ILD slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.ILD = ...
        slider_update(handles.sliderILD, handles.editILD);
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderABI_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: ABI slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.ABI = ...
        slider_update(handles.sliderABI, handles.editABI);
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderBC_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: BC slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.BC = ...
        slider_update(handles.sliderBC, handles.editBC);
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderFreq_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Freq slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.Freq = ...
        slider_update(handles.sliderFreq, handles.editFreq);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderBW_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: BW slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.BW = ...
        slider_update(handles.sliderBW, handles.editBW);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function slidersAMp_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: sAM percent slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box 
    handles.h2.search.sAMp = ...
        slider_update(handles.slidersAMp, handles.editsAMp);
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function slidersAMf_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: sAM frequency slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box 
    handles.h2.search.sAMf = ...
        slider_update(handles.slidersAMf, handles.editsAMf);
	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function sliderITD_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: ITD slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.search.ITD = ...
        slider_update(handles.sliderITD, handles.editITD);
	guidata(hObject, handles);
end

%% SEARCH module - editboxes
function editLatt_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Ratt slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.Latt = ...
        text_update(handles.editLatt, handles.sliderLatt, ...
                    handles.h2.search.limits.Latt);
    guidata(hObject, handles);
end
function editRatt_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Ratt text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.Ratt = ...
        text_update(handles.editRatt, handles.sliderRatt, ...
                    handles.h2.search.limits.Ratt);
    guidata(hObject, handles);
end
function editILD_Callback(hObject, eventdata, handles)
    % show message 
    str ='** search module: ILD text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.ILD = ...
        text_update(handles.editILD, handles.sliderILD, ...
                    handles.h2.search.limits.ILD);
    guidata(hObject, handles);
end
function editABI_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: ABI text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.ABI = ...
        text_update(handles.editABI, handles.sliderABI, ...
                    handles.h2.search.limits.ABI);
    guidata(hObject, handles);
end
function editBC_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: BC text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.BC = ...
        text_update(handles.editBC, handles.sliderBC, ...
                    handles.h2.search.limits.BC);
    guidata(hObject, handles);
end


function editFreq_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Freq text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.Freq = ...
        text_update(handles.editFreq, handles.sliderFreq, handles.h2.search.limits.Freq);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    guidata(hObject, handles);
end
function editBW_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: BW text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.BW = ...
        text_update(handles.editBW, handles.sliderBW, handles.h2.search.limits.BW);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    guidata(hObject, handles);
end
function editsAMp_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: sAM percent text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.sAMp = ...
        text_update(handles.editsAMp, handles.slidersAMp, ...
                    handles.h2.search.limits.sAMp);
    guidata(hObject, handles);
end
function editsAMf_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: sAM frequency text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.sAMf = ...
        text_update(handles.editsAMf, handles.slidersAMf, ...
                    handles.h2.search.limits.sAMf);
    guidata(hObject, handles);
end
function editITD_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: ITD text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.search.ITD = ...
        text_update(handles.editITD, handles.sliderITD, ...
                    handles.h2.search.limits.ITD);
    guidata(hObject, handles);
end
function editFmax_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Fmax text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check value 
    tmp = read_ui_str(hObject, 'n');
    if isnan(tmp)
        disp('warning: Fmax in not numeric. Reverting to orginal value'); 
        update_ui_str(hObject, handles.h2.search.Fmax);
        return;
    end
    if ~checklim(tmp, handles.h2.search.limits.Freq) % check limits
        disp('warning: Fmax is out of range. Reverting to orginal value'); 
        update_ui_str(hObject, handles.h2.search.Fmax);
        return;
    end
    % update corresponding edit boxes and sliders 
	handles.h2.search.Fmax = tmp;
    [f,bw] = guiFBWupdate(handles.h2.search.Fmax, handles.h2.search.Fmin, ...
        handles.h2.search.stimtype, handles);
    handles.h2.search.Freq = f;
    handles.h2.search.BW = bw;
	guidata(hObject, handles);
end
function editFmin_Callback(hObject, eventdata, handles)
    % show message 
    str = '** search module: Fmin text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check value 
    tmp = read_ui_str(hObject, 'n');
    if isnan(tmp)
        disp('warning: Fmin in not numeric. Reverting to orginal value'); 
        update_ui_str(hObject, handles.h2.search.Fmin);
        return;
    end
    if ~checklim(tmp, handles.h2.search.limits.Freq) % check limits
        disp('warning: Fmin is out of range. Reverting to orginal value'); 
        update_ui_str(hObject, handles.h2.search.Fmin);
        return;
    end
    % update corresponding edit boxes and sliders 
	handles.h2.search.Fmin = tmp;
    [f,bw] = guiFBWupdate(handles.h2.search.Fmax, handles.h2.search.Fmin, ...
        handles.h2.search.stimtype, handles);
    handles.h2.search.Freq = f;
    handles.h2.search.BW = bw;
	guidata(hObject, handles);
end

%% SEARCH module - radiobuttons
function radioSearchStim_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** search module: stimulus type changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioSearchStimNoise'
            disp('noise selected')
            handles.h2.search.stimtype = 'NOISE'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
        case 'radioSearchStimTone'
            disp('tone selected')
            handles.h2.search.stimtype = 'TONE'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
        case 'radioSearchStimAMnoise'
            disp('AM noise selected')
            handles.h2.search.stimtype = 'AMNOISE'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
        case 'radioSearchStimAMtone'
            disp('AM tone selected')
            handles.h2.search.stimtype = 'AMTONE'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
    end
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    guidata(hObject, handles);
    HPSearch2c_updateUI(handles,'SEARCH:FREQ');
end

%% auxiliary function for updating Fmin and Fmax from F and BW
function [minF, maxF] = guiFminmaxUpdate(F,BW,lim,type,handles)
    type = upper(type);
    if strcmp(type,'NOISE') || strcmp(type,'AMNOISE')
        maxF = round(F+BW/2);
        minF = round(F-BW/2);
        if minF < lim(1)
            disp('warning: Min Freq is too low, using lowest possible setting');
            minF = lim(1); 
        end
        if maxF > lim(2)
            disp('warning: Max Freq is too high, using highest possible setting');
            maxF = lim(2); 
        end
    else % 'TONE' or 'AMTONE'
        maxF = F;
        minF = F;
    end
    update_ui_str(handles.editFmax, maxF);
	update_ui_str(handles.editFmin, minF);
end
%% auxiliary function for updating F and BW from Fmin and Fmax
function [F, BW] = guiFBWupdate(Fmax,Fmin,type,handles)
    F = round((Fmax+Fmin)/2);
    type = upper(type);
    if strcmp(type,'NOISE') || strcmp(type,'AMNOISE')
        BW = Fmax-Fmin;  
    else % note: when 'TONE' is selected, Fmax and Fmin should be disabled
        BW = 0;
    end 
    update_ui_val(handles.sliderFreq, F);
    update_ui_str(handles.editFreq, F);
    update_ui_val(handles.sliderBW, BW);
    update_ui_str(handles.editBW, BW);
end

%% Settings module - button callbacks
function buttonSaveSettings_Callback(hObject, eventdata, handles)
    % show message 
    str = '** settings: save settings clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % ask user for a file name 
	[fname, fpath] = ...
        uiputfile('*_HP2settings.mat', 'Save HPSearch2c settings file...');
	if fname == 0 % return if user hits CANCEL button
		disp('saving cancelled...');
		return;
    end
	% copy setting data to settingdata structure
    settingdata.stimulus = handles.h2.stimulus;
    settingdata.tdt = handles.h2.tdt;
    settingdata.channels = handles.h2.channels;
    settingdata.analysis = handles.h2.analysis;
    settingdata.plots = handles.h2.plots;
    settingdata.curve = handles.h2.curve; 
    settingdata.click = handles.h2.click; 
    settingdata.paramBF = handles.h2.paramBF;
    settingdata.paramITD = handles.h2.paramITD;
    settingdata.paramILD = handles.h2.paramILD;
    settingdata.paramABI = handles.h2.paramABI;
    settingdata.paramBC = handles.h2.paramBC;
    settingdata.paramsAMp = handles.h2.paramsAMp;
    settingdata.paramsAMf = handles.h2.paramsAMf;
    settingdata.paramCF = handles.h2.paramCF;
    settingdata.paramCD = handles.h2.paramCD;
    settingdata.paramPH = handles.h2.paramPH;
    settingdata.paramCurrent = handles.h2.paramCurrent;
	% save data
    disp(['Saving settings to ' fname]);
    save(fullfile(fpath, fname), '-MAT', 'settingdata');
end
%--------------------------------------------------------------------------
function buttonLoadSettings_Callback(hObject, eventdata, handles)
    % show message 
    str = '** settings: load settings clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % ask user for a file name 
	[fname, fpath] = ...
        uigetfile('*_HP2settings.mat', 'Load HPSearch2c settings file...');
	if fname == 0 % return if user hits CANCEL button
		disp('loading cancelled...');
		return;
    end
	% load data
	disp(['Loading settings from ' fname])
	load(fullfile(fpath, fname), 'settingdata');
    % copy loaded data to handles.h2
    handles.h2.stimulus = settingdata.stimulus;
    handles.h2.tdt = settingdata.tdt;
    handles.h2.channels = settingdata.channels;
    handles.h2.analysis = settingdata.analysis;
    handles.h2.plots = settingdata.plots;
    handles.h2.curve = settingdata.curve; 
    handles.h2.click = settingdata.click; 
    handles.h2.paramBF = settingdata.paramBF;
    handles.h2.paramITD = settingdata.paramITD;
    handles.h2.paramILD = settingdata.paramILD;
    handles.h2.paramABI = settingdata.paramABI;
    handles.h2.paramBC = settingdata.paramBC;
    handles.h2.paramsAMp = settingdata.paramsAMp;
    handles.h2.paramsAMf = settingdata.paramsAMf;
    handles.h2.paramCF = settingdata.paramCF;
    handles.h2.paramCD = settingdata.paramCD;
    handles.h2.paramPH = settingdata.paramPH;
    handles.h2.paramCurrent = settingdata.paramCurrent;
	guidata(hObject, handles);    
    % update GUI according to the loaded data
    HPSearch2c_updateUI(handles,'SEARCH');
    HPSearch2c_updateUI(handles,'STIMULUS');
    HPSearch2c_updateUI(handles,'TDT');
    HPSearch2c_updateUI(handles,'CHANNELS');
    HPSearch2c_updateUI(handles,'ANALYSIS');
    HPSearch2c_updateUI(handles,'CURVE');
    HPSearch2c_updateUI(handles,'CLICK');
    HPSearch2c_updateUI(handles,'PLOTS');
end

%% Calibration module - button callbacks
function buttonLoadCALL_Callback(hObject, eventdata, handles)
    % show message 
    str = '** calibration settings: Load CAL L clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % ask user for a file name 
	[fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load Cal data for LEFT earphone...');
	if fname == 0 % return if user hits CANCEL button 
		disp('loading cancelled...');
		return;
    end
    disp(['Loading LEFT earphone calibration data from ' fname])
    try % loading calibration file
		tmpcal = TytoLogy2_loadcal(fullfile(fpath, fname), 'L'); 
    catch % on error, tmpcal is empty
		tmpcal = [];
        return;
    end
    % if tmpcal is a struct, loading cal file was hopefully successful
    if isstruct(tmpcal)
		handles.h2.caldataL = tmpcal;
        % update calibration data path and filename settings
 		handles.h2.calinfo.fpathL = fpath;
 		handles.h2.calinfo.fnameL = fname;
        handles.h2.calinfo.loadedL = 1;
        handles.h2.calinfo.FminL = handles.h2.caldataL.Freqs(1);
        handles.h2.calinfo.FmaxL = handles.h2.caldataL.Freqs(end);
        update_ui_str(handles.textCALfileL, fullfile(fpath, fname));
        % update Freq limits and slider parameters
        f0 = max([ handles.h2.calinfo.FminL handles.h2.calinfo.FminR handles.h2.search.limits.defaultFreq(1) ]);
        f1 = min([ handles.h2.calinfo.FmaxL handles.h2.calinfo.FmaxR handles.h2.search.limits.defaultFreq(2) ]);
        handles.h2.search.limits.Freq = [f0 f1];
 		slider_limits(handles.sliderFreq, handles.h2.search.limits.Freq);
        slider_update(handles.sliderFreq, handles.editFreq);
        % enabling Plot CAL button and Left ON checkbox
        enable_ui(handles.buttonPlotCAL);
        enable_ui(handles.checkLeftON); 
 	else
        errordlg(['Error loading calibration file ' fname], 'LoadCalL error'); 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function buttonLoadCALR_Callback(hObject, eventdata, handles)
    % show message 
    str = '** calibration settings: Load CAL R clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % ask user for a file name 
	[fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load Cal data for RIGHT earphone...');
	if fname == 0 % return if user hits CANCEL button 
		disp('loading cancelled...');
		return;
    end
    disp(['Loading RIGHT earphone calibration data from ' fname])
    try % loading calibration file
		tmpcal = TytoLogy2_loadcal(fullfile(fpath, fname), 'R'); 
    catch % on error, tmpcal is empty
		tmpcal = [];
        return;
    end
    % if tmpcal is a struct, loading cal file was hopefully successful
    if isstruct(tmpcal)
		handles.h2.caldataR = tmpcal;
        % update calibration data path and filename settings
 		handles.h2.calinfo.fpathR = fpath;
 		handles.h2.calinfo.fnameR = fname;
        handles.h2.calinfo.loadedR = 1;
        handles.h2.calinfo.FminR = handles.h2.caldataR.Freqs(1);
        handles.h2.calinfo.FmaxR = handles.h2.caldataR.Freqs(end);
    	update_ui_str(handles.textCALfileR, fullfile(fpath, fname));
        % update Freq limits and slider parameters
        f0 = max([ handles.h2.calinfo.FminL handles.h2.calinfo.FminR handles.h2.search.limits.defaultFreq(1) ]);
        f1 = min([ handles.h2.calinfo.FmaxL handles.h2.calinfo.FmaxR handles.h2.search.limits.defaultFreq(2) ]);
        handles.h2.search.limits.Freq = [f0 f1];
 		slider_limits(handles.sliderFreq, handles.h2.search.limits.Freq);
        slider_update(handles.sliderFreq, handles.editFreq);	
        % enabling Plot CAL button and Right ON checkbox
        enable_ui(handles.buttonPlotCAL);
        enable_ui(handles.checkRightON);
 	else
        errordlg(['Error loading calibration file ' fname], 'LoadCalR error'); 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function buttonPlotCAL_Callback(hObject, eventdata, handles)
    % show message 
    str = '** calibration settings: Plot CAL clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check if cal files have been loaded 
    calinfo = handles.h2.calinfo;
    if ~calinfo.loadedR && ~calinfo.loadedL  % neither L nor R is loaded
        disp('no cal files loaded');
        return;
    end
    TytoLogy2_plotcal(handles.h2.calinfo.loadedL, handles.h2.caldataL, ...
                      handles.h2.calinfo.loadedR, handles.h2.caldataR);
end
%--------------------------------------------------------------------------
function buttonDeleteCal_Callback(hObject, eventdata, handles)
    % show message 
    str = '** calibration settings: Delete CAL clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % delete cal data
    handles.h2.calinfo = HPSearch2c_init('CALINFO'); % reset filenames and flags
    handles.h2.caldataL = [];
    handles.h2.caldataR = [];
   	update_ui_str(handles.textCALfileL, 'unloaded');
   	update_ui_str(handles.textCALfileR, 'unloaded');
    handles.h2.search.LeftON = 0;
    handles.h2.search.RightON = 0;
    handles.h2.search.limits.Freq = handles.h2.search.limits.defaultFreq; % reset to default
    HPSearch2c_updateUI(handles,'SEARCH:ATTEN');
    % disabling Plot CAL button and LEFT ON and Right ON checkboxes
    disable_ui(handles.buttonPlotCAL);
    disable_ui(handles.checkLeftON);
    disable_ui(handles.checkRightON);
    guidata(hObject, handles);
end

%% Experiment module - editboxes
function editDate_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: date changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % Date field cannot be edited
    disp('Sorry, the Date field is not editable.');
    disp('Please change the clock of your computer, if you wish to change dates');
	update_ui_str(hObject, handles.h2.animal.Date);
   	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editAnimal_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: animal# changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.Animal = read_ui_str(hObject);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editUnit_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: unit# changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.Unit = read_ui_str(hObject);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editRec_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: rec# changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.Rec = read_ui_str(hObject);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editPen_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: penetration# changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.Pen = read_ui_str(hObject);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editAP_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: AP changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.AP = read_ui_str(hObject);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editML_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: ML changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.ML = read_ui_str(hObject);
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editDepth_Callback(hObject, eventdata, handles)
    % show message 
    str = '** experiment data settings: depth changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
	handles.h2.animal.Depth = read_ui_str(hObject);
    guidata(hObject, handles);
end

%% Stimulus module - editboxes
function editISI_Callback(hObject, eventdata, handles)
    % show message 
    str = '** stimulus settings: ISI changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.ISI)	% check limits
		handles.h2.stimulus.ISI = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.ISI);
    end
end
%--------------------------------------------------------------------------
function editDuration_Callback(hObject, eventdata, handles)
    % show message 
    str = '** stimulus settings: duration changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.Duration)	% check limits
		handles.h2.stimulus.Duration = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.Duration);
    end
end
%--------------------------------------------------------------------------
function editDelay_Callback(hObject, eventdata, handles)
    % show message 
    str = '** stimulus settings: delay changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.Delay)	% check limits
		handles.h2.stimulus.Delay = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.Delay);
    end
end
%--------------------------------------------------------------------------
function editRamp_Callback(hObject, eventdata, handles)
    % show message 
    str = '** stimulus settings: ramp changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.Ramp)	% check limits
		handles.h2.stimulus.Ramp = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.Ramp);
    end
end

%% Stimulus module - checkboxes
function checkRadVary_Callback(hObject, eventdata, handles)
    % show message 
    str = '** stimulus settings: radvary clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.stimulus.RadVary = read_ui_val(hObject); 
    guidata(hObject, handles); 
end
%--------------------------------------------------------------------------
function checkFrozenStim_Callback(hObject, eventdata, handles)
    % show message 
    str = '** stimulus settings: frozen stim clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.stimulus.Frozen = read_ui_val(hObject); 
    guidata(hObject, handles); 
end

%% TDT settings module - editboxes
function editAcqDuration_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: acq duration changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variables 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.AcqDuration)	% check limits
		handles.h2.tdt.AcqDuration = tmp;
        handles.h2.tdt.SweepPeriod = tmp + 10;
		update_ui_str(handles.editSweepPeriod, handles.h2.tdt.SweepPeriod);
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.AcqDuration);
    end
end
%--------------------------------------------------------------------------
function editSweepPeriod_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: sweep period changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % Sweep period cannot be changed directly 
    disp('Sorry, Sweep Period is not editable.');
    disp('Change AcqDuration instead.'); 
    disp('SweepPeriod is determined as AcqDuration + 10.');    
	update_ui_str(hObject, handles.h2.tdt.SweepPeriod);
   	guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editTTLPulseDur_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: TTL pulse dur changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.TTLPulseDur)	% check limits
		handles.h2.tdt.TTLPulseDur = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.TTLPulseDur);
    end
end
%--------------------------------------------------------------------------
function editCircuitGain_Callback(hObject, eventdata, handles)
%     % show message 
%     str = '** TDT settings: circuit gain changed';
%     set(handles.textMessage, 'String', str);
%     if(handles.DEBUG); disp(str); end % debug mode
%     % check limits and update corresponding variable 
%     tmp = read_ui_str(hObject, 'n');
% 	if checklim(tmp, handles.h2.tdt.limits.CircuitGain)	% check limits
% 		handles.h2.tdt.CircuitGain = tmp;
%         guidata(hObject, handles);
%     else % resetting to old value
% 		update_ui_str(hObject, handles.h2.tdt.CircuitGain);
%     end
end
%--------------------------------------------------------------------------
function editHPFreq_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: HP freq changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.HPFreq)	% check limits
		handles.h2.tdt.HPFreq = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.HPFreq);
    end
end
%--------------------------------------------------------------------------
function editLPFreq_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: LP freq changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.LPFreq)	% check limits
		handles.h2.tdt.LPFreq = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.LPFreq);
    end
end

%% TDT settings module - checkboxes
function checkHighPass_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: use high pass clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.tdt.HPEnable = read_ui_val(hObject); 
    guidata(hObject, handles); 
end
%--------------------------------------------------------------------------
function checkLowPass_Callback(hObject, eventdata, handles)
    % show message 
    str = '** TDT settings: use low pass clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.tdt.LPEnable = read_ui_val(hObject); 
    guidata(hObject, handles); 
end

%% I/O channel module - editboxes
function editInput_Callback(hObject, eventdata, handles)
    % show message 
    str = '** I/O channel settings: input channel changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.channels.InputChannel = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editOutputL_Callback(hObject, eventdata, handles)
    % show message 
    str = '** I/O channel settings: output channel L changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.channels.OutputChannelL = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function editOutputR_Callback(hObject, eventdata, handles)
    % show message 
    str = '** I/O channel settings: output channel R changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.channels.OutputChannelR = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
end

%% Spike Analysis module - editboxes
function editWindowWidth_Callback(hObject, eventdata, handles)
    % show message 
    str = '** spike analysis settings: window width changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.WindowWidth)	% check limits
		handles.h2.analysis.WindowWidth = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.WindowWidth);
    end
end
%--------------------------------------------------------------------------
function editStartTime_Callback(hObject, eventdata, handles)
    % show message 
    str = '** spike analysis settings: start time changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.StartTime)	% check limits
		handles.h2.analysis.StartTime = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.StartTime);
    end
end
%--------------------------------------------------------------------------
function editEndTime_Callback(hObject, eventdata, handles)
    % show message 
    str = '** spike analysis settings: end time changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.EndTime)	% check limits
		handles.h2.analysis.EndTime = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.EndTime);
    end
end
%--------------------------------------------------------------------------
function editThres_Callback(hObject, eventdata, handles)
    % show message 
    str = '** spike analysis settings: threshold SD changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.ThresSD)	% check limits
		handles.h2.analysis.ThresSD = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.ThresSD);
    end
end

%% Threshold Control module - radio buttons
% threshold
function radioThreshold_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** spike analysis settings: threshold type changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
    % hSelected = hObject; % for R2007a
    % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioThAuto'
            disp('auto threshold selected')
            handles.h2.analysis.ThAuto = 1; 
            disable_ui(handles.sliderManualTh);
            disable_ui(handles.editManualTh);
        case 'radioThManual'
            disp('manual threshold selected')
            handles.h2.analysis.ThAuto = 0; 
            enable_ui(handles.sliderManualTh);
            enable_ui(handles.editManualTh);
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
% Y axis
function radioYaxis_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** plot panel settings: Y limit type changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioYAuto'
            disp('auto Y axis selected')
            handles.h2.analysis.YAuto = 1; 
            disable_ui(handles.sliderManualY);
            disable_ui(handles.editManualY);
        case 'radioYManual'
            disp('manual Y axis selected')
            handles.h2.analysis.YAuto = 0; 
            enable_ui(handles.sliderManualY);
            enable_ui(handles.editManualY);
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
% detection
function radioDetection_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** spike analysis settings: threshold ditection changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioPeakAuto'
            disp('Auto peak detection selected')
            handles.h2.analysis.Peak = 0; 
        case 'radioPeakTop'
            disp('Top detection selected')
            handles.h2.analysis.Peak = 1; 
        case 'radioPeakBottom'
            disp('Bottom detection selected')
            handles.h2.analysis.Peak = -1; 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
% scale
function radioScale_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** manual control settings: Scale factor changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioScale0'
            disp('1000 mV (1 V) selected')
            handles.h2.analysis.Scale = 1.0; 
        case 'radioScale1'
            disp('100 mV (0.1 V) selected')
            handles.h2.analysis.Scale = 1.0e-1; 
        case 'radioScale2'
            disp('10 mV (0.01 V) selected')
            handles.h2.analysis.Scale = 1.0e-2; 
        case 'radioScale3'
            disp('1 mV (0.001 V) selected')
            handles.h2.analysis.Scale = 1.0e-3; 
        case 'radioScale4'
            disp('0.1 mV (100 uV) selected')
            handles.h2.analysis.Scale = 1.0e-4; 
        case 'radioScale5'
            disp('0.01 mV (10 uV) selected')
            handles.h2.analysis.Scale = 1.0e-5; 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
% sign
function radioSign_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** manual control settings: Threshold Sign changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioThPlus'
            disp('Positive Threshold selected')
            handles.h2.analysis.Sign = 1.0; 
        case 'radioThMinus'
            disp('Negative Threshold selected')
            handles.h2.analysis.Sign = -1.0; 
    end
    guidata(hObject, handles);
end

%% Threshold Control module - slider
function sliderManualTh_Callback(hObject, eventdata, handles)
    % show message 
    str = '** manual control: Threshold slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.analysis.Threshold = ...
        slider_update(handles.sliderManualTh, handles.editManualTh, '%.1f');
	guidata(hObject, handles);
end
function sliderManualY_Callback(hObject, eventdata, handles)
    % show message 
    str = '** manual control: Y axis slider changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding edit box
    handles.h2.analysis.Yaxis = ...
        slider_update(handles.sliderManualY, handles.editManualY, '%.1f');
	guidata(hObject, handles);
end

%% Threshold Control module - editboxes
function editManualTh_Callback(hObject, eventdata, handles)
    % show message 
    str = '** manual control: Threshold text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.analysis.Threshold = ...
        text_update(handles.editManualTh, handles.sliderManualTh, ...
                    handles.h2.analysis.limits.Threshold, '%.1f');
    guidata(hObject, handles);
end
function editManualY_Callback(hObject, eventdata, handles)
    % show message 
    str = '** manual control: Y axis text changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding slider 
	handles.h2.analysis.Yaxis = ...
        text_update(handles.editManualY, handles.sliderManualY, ...
                    handles.h2.analysis.limits.Yaxis, '%.1f');
    guidata(hObject, handles);
end

%% Plot Panels module - buttons
function buttonAllOn_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: All On clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding checkboxes
    set(handles.checkAxesResp, 'Checked', 'On' );
    set(handles.checkAxesRaster, 'Checked', 'On' );
    set(handles.checkAxesCurve, 'Checked', 'On' );
    set(handles.checkAxesUpclose, 'Checked', 'On' );
    set(handles.checkAxesPSTH, 'Checked', 'On' );
    set(handles.checkAxesISIH, 'Checked', 'On' );
    % save corresponding flags
    handles.h2.plots.plotResp = 1; 
    handles.h2.plots.plotRaster = 1; 
    handles.h2.plots.plotCurve = 1; 
    handles.h2.plots.plotUpclose = 1; 
    handles.h2.plots.plotPSTH = 1; 
    handles.h2.plots.plotISIH = 1; 
    guidata(handles.HPSearch2b, handles);
end
%--------------------------------------------------------------------------
function buttonAllOff_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: All Off clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding checkboxes
    set(handles.checkAxesResp, 'Checked', 'Off' );
    set(handles.checkAxesRaster, 'Checked', 'Off' );
    set(handles.checkAxesCurve, 'Checked', 'Off' );
    set(handles.checkAxesUpclose, 'Checked', 'Off' );
    set(handles.checkAxesPSTH, 'Checked', 'Off' );
    set(handles.checkAxesISIH, 'Checked', 'Off' );
    % save corresponding flags
    handles.h2.plots.plotResp = 0; 
    handles.h2.plots.plotRaster = 0; 
    handles.h2.plots.plotCurve = 0; 
    handles.h2.plots.plotUpclose = 0; 
    handles.h2.plots.plotPSTH = 0; 
    handles.h2.plots.plotISIH = 0; 
    guidata(handles.HPSearch2b, handles);
    % clear all plots
    cla(handles.axesResp);
    cla(handles.axesRaster);
    cla(handles.axesCurve);
    cla(handles.axesUpclose);
    cla(handles.axesPSTH);
    cla(handles.axesISIH);
end
%--------------------------------------------------------------------------
function buttonClearPlot_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** clear plot';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % disable UI 
%     disable_ui(hObject); 
    % clear plotting windows
    cla(handles.axesUpclose);
    cla(handles.axesResp);
    cla(handles.axesRaster);
    cla(handles.axesPSTH);
    cla(handles.axesISIH);
    cla(handles.axesCurve);
    % if search, curve, or click is running, then the plotting routine
    % should re-enable the clear plot button
%     if ( ~read_ui_val(handles.buttonSearch) && ...
%          ~read_ui_val(handles.buttonCurve) && ...
%          ~read_ui_val(handles.buttonClick) )
%         enable_ui(handles.buttonClearPlot);
%         update_ui_val(handles.buttonClearPlot, 0);
%     end
end

%% Plot Panels module - checkboxes
function checkAxesResp_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: Response checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable
    tmp = get( hObject, 'Checked' );
    if( strcmpi( tmp, 'On' )),
        handles.h2.plots.plotResp = 0;
        set( hObject, 'Checked', 'Off' );
    else
        handles.h2.plots.plotResp = 1;
        set( hObject, 'Checked', 'On' );
    end
    % if unchecked, then clear the plot window
    if(~handles.h2.plots.plotResp)
        cla(handles.axesResp);
    end
    % save handles structure
    guidata(handles.HPSearch2b, handles); 
end
function checkAxesRaster_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: Raster checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable
    tmp = get( hObject, 'Checked' );
    if( strcmpi( tmp, 'On' )),
        handles.h2.plots.plotRaster = 0;
        set( hObject, 'Checked', 'Off' );
    else
        handles.h2.plots.plotRaster = 1;
        set( hObject, 'Checked', 'On' );
    end
    % if unchecked, then clear the plot window
    if(~handles.h2.plots.plotRaster)
        cla(handles.axesRaster);
    end
    % save handles structure
    guidata(handles.HPSearch2b, handles); 
end
function checkAxesPSTH_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: PSTH checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable
    tmp = get( hObject, 'Checked' );
    if( strcmpi( tmp, 'On' )),
        handles.h2.plots.plotPSTH = 0;
        set( hObject, 'Checked', 'Off' );
    else
        handles.h2.plots.plotPSTH = 1;
        set( hObject, 'Checked', 'On' );
    end
    % if unchecked, then clear the plot window
    if(~handles.h2.plots.plotPSTH)
        cla(handles.axesPSTH);
    end
    % save handles structure
    guidata(handles.HPSearch2b, handles); 
end
function checkAxesCurve_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: Curve checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable
    tmp = get( hObject, 'Checked' );
    if( strcmpi( tmp, 'On' )),
        handles.h2.plots.plotCurve = 0;
        set( hObject, 'Checked', 'Off' );
    else
        handles.h2.plots.plotCurve = 1;
        set( hObject, 'Checked', 'On' );
    end
    % if unchecked, then clear the plot window
    if(~handles.h2.plots.plotCurve)
        cla(handles.axesCurve);
    end
    % save handles structure
    guidata(handles.HPSearch2b, handles);
end 
function checkAxesUpclose_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: Upclose checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable
    tmp = get( hObject, 'Checked' );
    if( strcmpi( tmp, 'On' )),
        handles.h2.plots.plotUpclose = 0;
        set( hObject, 'Checked', 'Off' );
    else
        handles.h2.plots.plotUpclose = 1;
        set( hObject, 'Checked', 'On' );
    end
    % if unchecked, then clear the plot window
    if(~handles.h2.plots.plotUpclose)
        cla(handles.axesUpclose);
    end
    % save handles structure
    guidata(handles.HPSearch2b, handles); 
end
function checkAxesISIH_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: ISIH checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable
    tmp = get( hObject, 'Checked' );
    if( strcmpi( tmp, 'On' )),
        handles.h2.plots.plotISIH = 0;
        set( hObject, 'Checked', 'Off' );
    else
        handles.h2.plots.plotISIH = 1;
        set( hObject, 'Checked', 'On' );
    end
    % if unchecked, then clear the plot window
    if(~handles.h2.plots.plotISIH)
        cla(handles.axesISIH);
    end
    % save handles structure
    guidata(handles.HPSearch2b, handles); 
end

%% Plot Panels module - editbox
function editRaster_Callback(hObject, eventdata, handles)
    handles = guidata( handles.HPSearch2b );
    % show message 
    str = '** plot panel settings: Raster# changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.Raster)	% check limits
		handles.h2.analysis.Raster = tmp;
        guidata(handles.HPSearch2b, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.Raster);
    end
end

%% Curves Panel - editboxes
function editCurveReps_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: #Reps changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checkCurveLimits(tmp, handles.h2.stimulus.limits.Reps) % check limits
        handles.h2.paramCurrent.Reps = tmp;
        HPSearch2c_storecurveparams; % save current parameters 
        guidata(handles.HPSearch2b, handles);
    else % revert to old string
        disp(sprintf('# Reps out of bounds [%d %d]', ... 
             handles.h2.stimulus.limits.Reps(1), handles.h2.stimulus.limits.Reps(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.Reps);
    end
end
%--------------------------------------------------------------------------
function editCurveITD_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: ITD changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad ITD string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.ITDstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.ITD)  % check limits
        handles.h2.paramCurrent.ITDstring = tmpstr;
        handles.h2.paramCurrent.ITD = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ITD(1), handles.h2.search.limits.ITD(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.ITDstring);
    end
end
%--------------------------------------------------------------------------
function editCurveILD_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: ILD changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad ILD string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.ILDstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.ILD)  % check limits
        handles.h2.paramCurrent.ILDstring = tmpstr;
        handles.h2.paramCurrent.ILD = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('ILD range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ILD(1), handles.h2.search.limits.ILD(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.ILDstring);
    end
end
%--------------------------------------------------------------------------
function editCurveABI_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: ABI changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad ABI string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.ABIstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.ABI)  % check limits
        handles.h2.paramCurrent.ABIstring = tmpstr;
        handles.h2.paramCurrent.ABI = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('ABI range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ABI(1), handles.h2.search.limits.ABI(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.ABIstring);
    end
end
%--------------------------------------------------------------------------
function editCurveFreq_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: Freq changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad Freq string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.Freqstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.Freq)  % check limits
        handles.h2.paramCurrent.Freqstring = tmpstr;
        handles.h2.paramCurrent.Freq = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('Freq range out of bounds [%d %d]', ... 
             handles.h2.search.limits.Freq(1), handles.h2.search.limits.Freq(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.Freqstring);
    end
end
%--------------------------------------------------------------------------
function editCurveBC_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: BC changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad BC string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.BCstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.BC)  % check limits
        handles.h2.paramCurrent.BCstring = tmpstr;
        handles.h2.paramCurrent.BC = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('BC range out of bounds [%d %d]', ... 
             handles.h2.search.limits.BC(1), handles.h2.search.limits.BC(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.BCstring);
    end
end
%--------------------------------------------------------------------------
function editCurvesAMp_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: sAM percent changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad sAM percent string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.sAMpstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.sAMp)  % check limits
        handles.h2.paramCurrent.sAMpstring = tmpstr;
        handles.h2.paramCurrent.sAMp = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('sAM percent range out of bounds [%d %d]', ... 
             handles.h2.search.limits.sAMp(1), handles.h2.search.limits.sAMp(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.sAMpstring);
    end
end
%--------------------------------------------------------------------------
function editCurvesAMf_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: sAM freq changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad sAM freq string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.paramCurrent.sAMfstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.search.limits.sAMf)  % check limits
        handles.h2.paramCurrent.sAMfstring = tmpstr;
        handles.h2.paramCurrent.sAMf = tmparr;
        HPSearch2c_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('sAM freq range out of bounds [%d %d]', ... 
             handles.h2.search.limits.sAMf(1), handles.h2.search.limits.sAMf(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.sAMfstring);
    end
end

%% Curves Panel - checkboxes
function checkCurveSpont_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: Spont checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.curve.Spont = read_ui_val(hObject); 
    guidata(hObject, handles); 
end
%--------------------------------------------------------------------------
function checkCurveTemp_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: Temp checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.curve.Temp = read_ui_val(hObject); 
    guidata(hObject, handles); 
end
%--------------------------------------------------------------------------
function checkCurveSaveStim_Callback(hObject, eventdata, handles)
    % show message 
    str = '** curves module: SaveStim checkbox clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % update corresponding variable 
    handles.h2.curve.SaveStim = read_ui_val(hObject); 
    guidata(hObject, handles); 
end

%% Curves Panel - radio buttons
function radioCurveType_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** curves module: curve type changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveTypeBF'
            disp('BF curve selected')
            handles.h2.paramCurrent = handles.h2.paramBF;
            handles.h2.curve.stimtype = 'TONE'; 
        case 'radioCurveTypeITD'
            disp('ITD curve selected')
            handles.h2.paramCurrent = handles.h2.paramITD;
            handles.h2.curve.side = 'BOTH'; 
        case 'radioCurveTypeILD'
            disp('ILD curve selected')
            handles.h2.paramCurrent = handles.h2.paramILD;
            handles.h2.curve.side = 'BOTH'; 
        case 'radioCurveTypeABI'
            disp('ABI curve selected')
            handles.h2.paramCurrent = handles.h2.paramABI;
        case 'radioCurveTypeBC'
            disp('BC curve selected')
            handles.h2.paramCurrent = handles.h2.paramBC;
            handles.h2.curve.side = 'BOTH'; 
            handles.h2.curve.stimtype = 'NOISE'; 
        case 'radioCurveTypeFILDL'
            disp('FILDL curve selected')
            handles.h2.paramCurrent = handles.h2.paramFILDL;
            handles.h2.curve.side = 'BOTH'; 
        case 'radioCurveTypeFILDR'
            disp('FILDR curve selected')
            handles.h2.paramCurrent = handles.h2.paramFILDR;
            handles.h2.curve.side = 'BOTH';
        case 'radioCurveTypeBeat'
            disp('Beat curve selected')
            handles.h2.paramCurrent = handles.h2.paramBeat;
            handles.h2.curve.side = 'BOTH';
            handles.h2.curve.stimtype = 'TONE';
        case 'radioCurveTypesAMp'
            disp('sAM percent curve selected')
            handles.h2.paramCurrent = handles.h2.paramsAMp;
%            handles.h2.curve.stimtype = 'NOISE'; % commented out to enable AM tone 
        case 'radioCurveTypesAMf'
            disp('sAM freq curve selected')
            handles.h2.paramCurrent = handles.h2.paramsAMf;
%            handles.h2.curve.stimtype = 'NOISE'; % commented out to enable AM tone 
        case 'radioCurveTypeCF'
            disp('CF curve selected')
            handles.h2.paramCurrent = handles.h2.paramCF;
            handles.h2.curve.stimtype = 'TONE'; 
        case 'radioCurveTypeCD'
            disp('CD curve selected')
            handles.h2.paramCurrent = handles.h2.paramCD;
            handles.h2.curve.side = 'BOTH'; 
        case 'radioCurveTypePH'
            disp('Phase Histogram selected')
            handles.h2.paramCurrent = handles.h2.paramPH;
    end
    guidata(hObject, handles);
    % update the GUI 
    HPSearch2c_updateUI(handles,'CURVE');
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function radioCurveStim_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** curves module: stimulus type changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value 
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveStimNoise'
            disp('noise selected')
            handles.h2.curve.stimtype = 'NOISE'; 
        case 'radioCurveStimTone'
            disp('tone selected')
            handles.h2.curve.stimtype = 'TONE'; 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function radioCurveSide_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** curves module: stimulus side changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value 
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveSideBoth'
            disp('binaural selected')
            handles.h2.curve.side = 'BOTH'; 
        case 'radioCurveSideLeft'
            disp('left selected')
            handles.h2.curve.side = 'LEFT'; 
        case 'radioCurveSideRight'
            disp('right selected')
            handles.h2.curve.side = 'RIGHT'; 
    end
    guidata(hObject, handles);
end


%% Clicks Panel - editboxes
function editClickSamples_Callback(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: #Samples changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Samples) % check limits
        tmp = ceil(tmp/2)*2; %% round to even number
        update_ui_str(hObject, tmp); %% update edit box 
        handles.h2.click.Samples = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Samples);
    end
end
%--------------------------------------------------------------------------
function editClickReps_Callback(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: #Reps changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Reps) % check limits
        handles.h2.click.Reps = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Reps);
    end
end
%--------------------------------------------------------------------------
function editClickITD_Callback(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: ITD changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad ITD string') % if something goes bad with array
        update_ui_str(hObject, handles.h2.click.ITDstring); % revert to old string 
        return;
    end
    if checkCurveLimits(tmparr, handles.h2.click.limits.ITD) % check limits
        handles.h2.click.ITDstring = tmpstr;
        handles.h2.click.ITD = tmparr;
        guidata(hObject, handles);
    else % if out of limits
        disp(sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.click.limits.ITD(1), handles.h2.click.limits.ITD(2)));
        update_ui_str(hObject, handles.h2.click.ITDstring);
    end
end
%--------------------------------------------------------------------------
function editClickLatten_Callback(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: Latten changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Latten) % check limits
        handles.h2.click.Latten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Latten);
    end
end
%--------------------------------------------------------------------------
function editClickRatten_Callback(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: Ratten changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Ratten) % check limits
        handles.h2.click.Ratten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Ratten);
    end
end

%% Clicks Panel - radio buttons
function radioClickType_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: stimulus type changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value 
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioClickTypeCond'
            disp('condensed click selected')
            handles.h2.click.clicktype = 'COND'; 
        case 'radioClickTypeRare'
            disp('rare click selected')
            handles.h2.click.clicktype = 'RARE'; 
        case 'radioClickTypePlusMinus'
            disp('plus/minus click selected')
            handles.h2.click.clicktype = 'PLUSMINUS'; 
        case 'radioClickTypeMinusPlus'
            disp('minus/plus click selected')
            handles.h2.click.clicktype = 'MINUSPLUS'; 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function radioClickSide_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** clicks module: stimulus side changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value 
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioClickSideBoth'
            disp('binaural click selected')
            handles.h2.click.side = 'BOTH'; 
        case 'radioClickSideLeft'
            disp('left click selected')
            handles.h2.click.side = 'LEFT'; 
        case 'radioClickSideRight'
            disp('right click selected')
            handles.h2.click.side = 'RIGHT'; 
    end
    guidata(hObject, handles);
end

%% External Stimulus Module - editboxes
function editExtStimReps_Callback(hObject, eventdata, handles)
    str = '** external stimulus module: Repetitions changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.extstim.limits.Reps) % check limits
        tmp = round(tmp); %% round to integer
        update_ui_str(hObject, tmp); %% update edit box 
        handles.h2.extstim.Reps = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.extstim.Reps);
    end
end
%--------------------------------------------------------------------------
function editExtStimITD_Callback(hObject, eventdata, handles)
    str = '** external stimulus module: ITD changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject);
    if isempty(strtrim(tmp)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmp);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    if ~isnumeric(tmparr(1)) % check if numeric
        disp('bad ITD string') % if something goes bad with array
        update_ui_str( hObject, handles.h2.extstim.ITDstring ); % revert to old string 
        return;
    end
    if( checkCurveLimits( tmparr, handles.h2.extstim.limits.ITD )), % check limits
        handles.h2.extstim.ITDstring = tmp;
        handles.h2.extstim.ITD = tmparr;
        guidata(hObject, handles);
    else % reset to old value
        disp(sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.extstim.limits.ITD( 1 ), handles.h2.extstim.limits.ITD( 2 )));
        update_ui_str(hObject, handles.h2.extstim.ITD);
    end
end
%--------------------------------------------------------------------------
function editExtStimLatten_Callback(hObject, eventdata, handles)
    str = '** external stimulus module: Latten changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.extstim.limits.Latten) % check limits
        handles.h2.extstim.Latten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.extstim.Latten);
    end
end
%--------------------------------------------------------------------------
function editExtStimRatten_Callback(hObject, eventdata, handles)
    % show message 
    str = '** external stimulus module: Ratten changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % check limits and update corresponding variable  
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.extstim.limits.Ratten) % check limits
        handles.h2.extstim.Ratten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.extstim.Ratten);
    end
end

%% External Stimulus Module - button
function buttonExtStimRun_Callback(hObject, eventdata, handles)
    % show message 
    str = '** Run (Ext) Stim button clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % define colors
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red
    ENABLECOLOR = [0.0 0.5 0.0];  % Dark Green	

    % set the flag to zero
    RunSuccessFlag = 0; % success=1, unfinished=0, aborted=-1, failed=-2
    
    % get the states of the button and TDTINIT 
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
	load(handles.h2.config.TDTLOCKFILE); % loading TDTINIT 
    %-----------------------------------------------------
    % buttonState=0 & TDTINIT=0 : (this should not happen: the button is disabled before TDT is initialized)
    % buttonState=1 & TDTINIT=0 : need to start TDT before starting stimulus
    % buttonState=0 & TDTINIT=1 : stop search stimulus
    % buttonState=1 & TDTINIT=1 : start search stimulus
    %-----------------------------------------------------
    
    % if user wants to start, check if TDT hardware has been initialized
    if ~TDTINIT
        disp([mfilename ': TDT Hardware is not initialized!! Cancelling search...']);
        % updating UI
        update_ui_val(hObject, 0);
        update_ui_str(hObject, 'Run Stim');
        set(hObject, 'ForegroundColor', ENABLECOLOR);
        RunSuccessFlag = -2; % failed
    end
    
    % if buttonState is 1 and TDT is running, then start stimulus
    % stimulus will remain ON, while "read_ui_val(hObject)=1"
    if(( RunSuccessFlag == 0 ) && ( buttonState ) && TDTINIT ), 
        disp('Starting search stimuli...')
        % updating UI and disabling other buttons
        update_ui_str(hObject, 'Stop');
        set(hObject, 'ForegroundColor', DISABLECOLOR);
        HPSearch2c_enableUIs(handles,'DISABLE');
        disable_ui(handles.buttonSearch);
        enable_ui(hObject);
        % go to main part of Search
        guidata(hObject, handles);
        HPSearch2c_RunStim; 
        
        % if succeeded then advance #Rec
        if RunSuccessFlag > 0 
            tmp = str2double(handles.h2.animal.Rec); 
            if ~isnan(tmp)
                handles.h2.animal.Rec = num2str(round(tmp+1));
            end
            % show outputfile again in command window
            display( extstimfile );
        end
    end 
    
    % updating animals info
    handles.h2.animal.Date = TytoLogy2_datetime('date');
    handles.h2.animal.Time = TytoLogy2_datetime('time');
    HPSearch2c_updateUI(handles,'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    HPSearch2c_enableUIs(handles,'ENABLE');
    update_ui_str(hObject, 'Run Stim');
    set(hObject, 'ForegroundColor', ENABLECOLOR);
    
    guidata(hObject,handles); 
end
%--------------------------------------------------------------------------
function buttonExtStimLoad_Callback(hObject, eventdata, handles)
    % show message 
    str = '** external stimulus settings: Load Stimulus clicked';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % ask user for a file name 
    [fname, fpath] = uigetfile( '*.wav', 'Load external stimulus...' );
    if fname == 0 % return if user hits CANCEL button 
		disp('loading cancelled...');
		return;
    end
    disp(['Loading stimulus data from ' fname])
    try % loading calibration file
        [ tmp_stim, stim_fs ] = wavread( fullfile( fpath, fname ));
    catch % on error, tmpcal is empty
		tmp_stim = [];
        stim_fs = [];
        return;
    end
    % if tmp_stim is not empty, loading was successful
    if( ~isempty( tmp_stim )),
        stim_info.shape = size( tmp_stim );
        stim_info.len = stim_info.shape( 1 )/stim_fs*1000;
        stim_info.fs = stim_fs;
        if( stim_info.shape( 2 ) == 1 ),
            stim_info.chan = 'mono';
        elseif( stim_info.shape( 2 ) == 2 ),
            stim_info.chan = 'stereo';
        else
            stim_info.chan = 'multi channel';
        end
        info_str = sprintf( '%.3f ms\n%d 1/Hz\n%s', stim_info.len, stim_info.fs, stim_info.chan );
        update_ui_str( handles.textExtStimInfo, info_str );
        
        % resample if necessary
        if( ~strcmpi( handles.TDThardware, 'NO_TDT' )),
            if( stim_fs ~= handles.outdev.Fs ),
                tmp_stim = resample( tmp_stim, stim_fs, handles.outdev.Fs );
                disp('resampled external stimulus')
            end
        end
        update_ui_str(handles.textExtStimFile, fullfile(fpath, fname));
        handles.h2.extstim.fileinfo.file = fullfile(fpath, fname);
        handles.h2.extstim.fileinfo.loaded = 1;
        handles.h2.extstim.fileinfo.nchan = stim_info.shape( 2 );
        handles.h2.extstim.fileinfo.sample_len = length( tmp_stim );
        handles.h2.extstim.fileinfo.stim_data = tmp_stim; % this will be the resampled stimulus
        handles.h2.extstim.fileinfo.rms = rms( tmp_stim );
        handles.h2.extstim.outsig = tmp_stim; % this is the stimulus that will be played
        
        % enabling Run Stim button
        enable_ui( handles.buttonExtStimRun );
    else
        handles.h2.extstim.fileinfo.loaded = 0;
        errordlg(['Error loading external stimulus file ' fname], 'External Stimulus: Load error'); 
    end
    guidata(hObject, handles);
end
function buttonExtStimLoad_ButtonDownFcn(hObject, eventdata, handles)
    % this function is only existent to prevent a really weird error :)
end

%% External Stimulus Module - radio buttons
function radioExtCal_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** external stimulus module: stimulus calibration changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value 
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioExtCalUse'
            disp('calibration selected')
            handles.h2.extstim.cal = 'EARCAL'; 
        case 'radioExtCalFlat'
            disp('flat calibration selected')
            handles.h2.extstim.cal = 'FLAT';
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function radioExtSide_SelectionChangeFcn(hObject, eventdata, handles)
    % show message 
    str = '** external stimulus module: stimulus side changed';
    set(handles.textMessage, 'String', str);
    if(handles.DEBUG); disp(str); end % debug mode
    % get selected value 
    if( handles.version > 2012 ), hSelected = get( hObject, 'SelectedObject' ); else hSelected = hObject; end
%     hSelected = hObject; % for R2007a
%     hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioExtSideBoth'
            disp('binaural selected')
            handles.h2.extstim.side = 'BOTH'; 
        case 'radioExtSideLeft'
            disp('left selected')
            handles.h2.extstim.side = 'LEFT'; 
        case 'radioExtSideRight'
            disp('right selected')
            handles.h2.extstim.side = 'RIGHT'; 
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------


%% Create Functions
function varargout = HPPlotWindow( varargin )
    handles = varargin{ 1 }; % copy input to be new output
    screen = get( 0, 'ScreenSize' );
    % create plot window
    handles.h_plotwin = figure( 'Units', 'Pixel', 'Position', ...
        [ screen( 3 )/4, screen( 4 )/4, ...
          800, 600 ], 'Menubar', 'None', ...
          'Name', 'Plot', 'CloseRequestFcn', @close_request );
      
    % create plot axes
	handles.axesResp = axes( 'Parent', handles.h_plotwin, ...
        'Units', 'Normalized', 'Position', [ 0.065  0.66 0.4013 0.255 ], ...
        'Tag', 'axesResp' );
    handles.axesCurve = axes( 'Parent', handles.h_plotwin, ...
        'Units', 'Normalized', 'Position', [ 0.5337 0.66 0.4013 0.255 ], ...
        'Tag', 'axesCurve' );
    handles.axesRaster = axes( 'Parent', handles.h_plotwin, ...
        'Units', 'Normalized', 'Position', [  0.065 0.355  0.4013 0.255 ], ...
        'Tag', 'axesRaster' );
    handles.axesUpclose = axes( 'Parent', handles.h_plotwin, ...
        'Units', 'Normalized', 'Position', [ 0.5337 0.355  0.4013 0.255 ], ...
        'Tag', 'axesUpclose' );
    handles.axesPSTH = axes( 'Parent', handles.h_plotwin, ...
        'Units', 'Normalized', 'Position', [ 0.065  0.05   0.4013 0.255 ], ...
        'Tag', 'axesPSTH' );        
    handles.axesISIH = axes( 'Parent', handles.h_plotwin, ...
        'Units', 'Normalized', 'Position', [ 0.5337 0.05   0.4013 0.255 ], ...
        'Tag', 'axesISIH' );
    
    % create plot menu (on which axes will be plotted)
    plot_menu = uimenu( 'Parent', handles.h_plotwin, 'Label', 'Plot Options' );
    handles.buttonAllOn      = uimenu( 'Parent', plot_menu, 'Label', 'All On', ...
        'Callback', {@buttonAllOn_Callback, guidata( handles.HPSearch2b )});
    handles.buttonAllOff     = uimenu( 'Parent', plot_menu, 'Label', 'All Off', ...
        'Callback', {@buttonAllOff_Callback, guidata( handles.HPSearch2b )});
    handles.checkAxesCurve   = uimenu( 'Parent', plot_menu, 'Label', 'Curve', ...
        'Checked', 'On', 'Separator', 'On', 'Callback', {@checkAxesCurve_Callback, guidata( handles.HPSearch2b )});
    handles.checkAxesISIH    = uimenu( 'Parent', plot_menu, 'Label', 'ISIH', ...
        'Checked', 'On', 'Callback', {@checkAxesISIH_Callback, guidata( handles.HPSearch2b )});
    handles.checkAxesUpclose = uimenu( 'Parent', plot_menu, 'Label', 'Upclose', ...
        'Checked', 'On', 'Callback', {@checkAxesUpclose_Callback, guidata( handles.HPSearch2b )});
    handles.checkAxesPSTH    = uimenu( 'Parent', plot_menu, 'Label', 'PSTH', ...
        'Checked', 'On', 'Callback', {@checkAxesPSTH_Callback, guidata( handles.HPSearch2b )});
    handles.checkAxesRaster  = uimenu( 'Parent', plot_menu, 'Label', 'Raster', ...
        'Checked', 'On', 'Callback', {@checkAxesRaster_Callback, guidata( handles.HPSearch2b )});
    handles.checkAxesResp    = uimenu( 'Parent', plot_menu, 'Label', 'Response', ...
    'Checked', 'On', 'Callback', {@checkAxesResp_Callback, guidata( handles.HPSearch2b )});
    
    % add clear button
    handles.buttonClearPlot  = uicontrol( 'Parent', handles.h_plotwin, 'Units', 'Normalized', ...
        'Position', [ 0.785 0.9425 0.15 0.05 ], 'Style', 'Push', 'String', ...
        'Clear All', 'Callback', {@buttonClearPlot_Callback, guidata( handles.HPSearch2b )});
    
    % add raster edit box
    uicontrol( 'Parent', handles.h_plotwin, 'Units', 'Normalized', 'Background', get( handles.h_plotwin, 'Color' ), ...
        'Position', [ 0.025 0.9425 0.06 0.035 ], 'Style', 'Text', 'String', 'Raster#' );
    handles.editRaster = uicontrol( 'Parent', handles.h_plotwin, 'Units', 'Normalized', ...
        'Position', [ 0.085 0.9425 0.09 0.05], 'Style', 'Edit', 'String', '30', ...
        'CreateFcn', {@editRaster_CreateFcn, guidata( handles.HPSearch2b )}, ...
        'Callback', {@editRaster_Callback, guidata( handles.HPSearch2b )});
    
    % set default toolbar
    set( handles.h_plotwin, 'Toolbar', 'Figure' );
    % find and remove toolbar objects
    temp = findall( handles.h_plotwin, 'ToolTipString', 'New Figure' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Open File' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Save Figure' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Print Figure' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Edit Plot' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Rotate 3D' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Data Cursor' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Insert Colorbar' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Insert Legend' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Hide Plot Tools' );
    delete( temp );
    temp = findall( handles.h_plotwin, 'ToolTipString', 'Show Plot Tools and Dock Figure' );
    delete( temp );
    
    % return handles
    varargout{ 1 } = handles;
    
    function close_request( varargin )
        % do nothing on close request
%         delete( gcbo ); % uncomment this only for debugging
    end
end

function popupTDT_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editMonitorGain_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editITD_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderITD_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editLatt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderLatt_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editILD_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderILD_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editRatt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderRatt_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editABI_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderABI_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editBC_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderBC_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editFreq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderFreq_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editBW_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderBW_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editFmax_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editFmin_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editsAMp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function slidersAMp_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editsAMf_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function slidersAMf_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editAcqDuration_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editSweepPeriod_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editTTLPulseDur_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCircuitGain_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editHPFreq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editLPFreq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editInput_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editOutputL_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editOutputR_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editDate_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editAnimal_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editUnit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editRec_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editPen_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editAP_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editML_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editDepth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editISI_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editDuration_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editDelay_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editRamp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editWindowWidth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editStartTime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editEndTime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editThres_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editRaster_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editManualTh_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderManualTh_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
function editManualY_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function sliderManualY_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
%--------------------------------------------------------------------------
function editRate_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editAutoTh_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editCurveReps_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurveITD_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurveILD_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurveABI_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurveFreq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurveBC_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurvesAMp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editCurvesAMf_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editClickReps_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editClickSamples_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editClickITD_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editClickLatten_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editClickRatten_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------
function editExtStimReps_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editExtStimITD_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editExtStimLatten_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function editExtStimRatten_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%--------------------------------------------------------------------------