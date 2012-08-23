function varargout = HPSearch2(varargin)
% HPSEARCH2 M-file for HPSearch2.fig
%   HPSEARCH2, by itself, creates a new HPSEARCH2 or raises the existing singleton*.
%
%   H = HPSEARCH2 returns the handle to a new HPSEARCH2 or the handle to
%      the existing singleton*.
%

% Last Modified by GUIDE v2.5 19-Mar-2012 18:25:57

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%   sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2): 2011-2012 by GA
%--------------------------------------------------------------------------
% ** Important Notes ** (Nov 2011, GA)
%   Parameters used in HPSearch2 are stored under the handles.h2 structure,
%   while parameters used in HPSearch are stored directly under handles 
%
% ** Important Notes ** (Feb 2012, GA)
%   This HPSearch2.m file handles only GUI-related issues. 
%   Most parts of recording and other components are delegated to 
%   corresponding subroutines (see below for a list). 
% 
%--------------------------------------------------------------------------
% [ Major Subroutines ] (info added by GA, Feb 2012)
% * HPSearch2_Opening.m     : called from HPSearch2_OpeningFcn
% * HPSearch2_Closing.m     : called from CloseRequestFcn
% * HPSearch2_TDTopen.m     : called from buttonTDTenable_Callback
% * HPSearch2_TDTclose.m    : called from buttonTDTenable_Callback
%
% * HPSearch2_Search.m      : called from buttonSearch_Callback
% * HPSearch2_Curve.m       : called from buttonCurve_Callback
% * HPSearch2_Click.m       : called from buttonClick_Callback
% 
% * HPSearch2_init.m        : used for initializing parameters
% * HPSearch2_config.m      : used for TDT hardware settings 
% * HPSearch2_updateUI.m    : used for updating the GUI
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
                   'gui_OpeningFcn', @HPSearch2_OpeningFcn, ...
                   'gui_OutputFcn',  @HPSearch2_OutputFcn, ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before HPSearch2 is made visible. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function HPSearch2_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.DEBUG = 1;  % 1:debug mode; 0:normal mode 
    guidata(hObject, handles);
    if(handles.DEBUG) % debug mode
        str = '** HPSearch2: opening function called';
        disp(str); set(handles.textMessage, 'String', str);
        enable_ui(handles.buttonShowVal);
        set(handles.buttonShowVal, 'Visible', 'on');
    end
    HPSearch2_Opening;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function varargout = HPSearch2_OutputFcn(hObject, eventdata, handles) 
    if(handles.DEBUG) % debug mode
        disp('** HPSearch2: output function called');
    end
    varargout{1} = hObject;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Cleaning up before closing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function CloseRequestFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** HPSearch2: closing function called';
        disp(str); set(handles.textMessage, 'String', str);
    end
    HPSearch2_Closing; 
    delete(hObject);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show Variable button (for debugging)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
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
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call Plot button (for viewing recorded data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonCallPlot_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** Call Plot button pressed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    TytoView_simpleView; % call plotting scripts
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup menu for selecting TDT hardware 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function popupTDT_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT hardware selection changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
        end
    % update handles.h2.config according to the selection of TDT
    handles.h2.config = HPSearch2_config(selectedStr);
    handles.h2.config.TDTLOCKFILE = handles.TDTLOCKFILE;
	guidata(hObject, handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enabling (or disabling) TDT hardware 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonTDTenable_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT Enable/Disable button clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red
    INITCOLOR   = [0.0 0.0 0.5];  % Dark Blue
    ENABLECOLOR = [0.0 0.5 0.0];  % Dark Green	

    % get the state of the buttons
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
    if buttonState % User pressed button to enable TDT Circuits
        set(handles.buttonTDTenable, 'ForegroundColor', INITCOLOR);
        update_ui_str(hObject, 'initializing')

        % Attempt to open TDT hardware
        [ tmphandles, tmpflag ] = HPSearch2_TDTopen(handles.h2.config);

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

        [ tmphandles, tmpflag ] = HPSearch2_TDTclose(handles.h2.config, ...
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
        else % tmpflag <= 0  % faied to stop TDT
            disp([mfilename ': failed to stop TDT...'])
            set(hObject, 'ForegroundColor', DISABLECOLOR);
            update_ui_str(hObject, 'TDT Disable')
        end

    end % end of "if buttonState"
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH button callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% When user clicks the SEARCH button, the value of the button is toggled; 
% If the button is "hi" (value == 1), the user wishes to start the run.
% If the button is "lo" (value == 0), the user wants to stop the run.  
% If start requested, also need to make sure the TDT is enabled. (SJS)
%--------------------------------------------------------------------------
function buttonSearch_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** SEARCH button clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
    % Note: loop in HPSearch2_Search.m finishes when "read_ui_val(hObject)=0"
    elseif ~buttonState && TDTINIT
        disp('Ending search stimuli...');
        % updating UI and enabling other buttons
        update_ui_str(hObject, 'Search')
        set(hObject, 'ForegroundColor', ENABLECOLOR);
        HPSearch2_enableUIs(handles,'ENABLE');

    % if buttonState is 1 and TDT is running, then start stimulus
    % stimulus will remain ON, while "read_ui_val(hObject)=1"
    else 
        disp('Starting search stimuli...')
        % updating UI and disabling other buttons
        update_ui_str(hObject, 'Stop');
        set(hObject, 'ForegroundColor', DISABLECOLOR);
        HPSearch2_enableUIs(handles,'DISABLE');
        % go to main part of Search
        guidata(hObject, handles);
        HPSearch2_Search; 
    end 
    guidata(hObject,handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Curve button callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonCurve_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** CURVE button clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end

    % updating UI and disabling other buttons
    HPSearch2_enableUIs(handles,'DISABLE');
    disable_ui(handles.buttonSearch);
    enable_ui(handles.buttonAbort);

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
        HPSearch2_Curve; 
        update_ui_str(hObject, 'Run Curve');

        % if succeeded then advance #Rec
        if CurveSuccessFlag > 0 
            tmp = str2double(handles.h2.animal.Rec); 
            if ~isnan(tmp)
                handles.h2.animal.Rec = num2str(round(tmp+1));
            end
        end
    end

    % updating animals info
    handles.h2.animal.Date = HPSearch2_datetime('date');
    handles.h2.animal.Time = HPSearch2_datetime('time');
    HPSearch2_updateUI(handles,'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    HPSearch2_enableUIs(handles,'ENABLE');
    enable_ui(handles.buttonSearch);
    disable_ui(handles.buttonAbort);

    % save handles structure 
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Click button callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonClick_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** CLICK button clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end

    % updating UI and disabling other buttons
    HPSearch2_enableUIs(handles,'DISABLE');
    disable_ui(handles.buttonSearch);
    enable_ui(handles.buttonAbort);

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
        HPSearch2_Click; 
        update_ui_str(hObject, 'Run Clicks');

        % if succeeded then advance #Rec
        if ClickSuccessFlag > 0 
            tmp = str2double(handles.h2.animal.Rec); 
            if ~isnan(tmp)
                handles.h2.animal.Rec = num2str(round(tmp+1));
            end
        end
    end 

    % updating animals info
    handles.h2.animal.Date = HPSearch2_datetime('date');
    handles.h2.animal.Time = HPSearch2_datetime('time');
    HPSearch2_updateUI(handles,'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    HPSearch2_enableUIs(handles,'ENABLE');
    enable_ui(handles.buttonSearch);
    disable_ui(handles.buttonAbort);

    % save handles structure 
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abort button callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonAbort_Callback(hObject, eventdata, handles)
    str = 'ABORTING!';
    disp(str); set(handles.textMessage, 'String', str);
    handles.ABORT = 1;
    % disable ui --- should be re-enabled in other (Curve or Click) routines 
    disable_ui(hObject); 
    guidata(hObject, handles);	
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for SEARCH controls --- L/R, attenuation and ITD settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function checkLeftON_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Left ON clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
    HPSearch2_updateUI(handles,'SEARCH:ATTEN');
%--------------------------------------------------------------------------
function checkRightON_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Right ON clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
    HPSearch2_updateUI(handles,'SEARCH:ATTEN');
%--------------------------------------------------------------------------
function sliderLatt_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Latt slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.Latt = ...
        slider_update(handles.sliderLatt, handles.editLatt);
    guidata(hObject, handles);
function editLatt_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str  = '** search module: Latt text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.Latt = ...
        text_update(handles.editLatt, handles.sliderLatt, handles.h2.search.limits.Latt);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderILD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: ILD slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.ILD = ...
        slider_update(handles.sliderILD, handles.editILD);
	guidata(hObject, handles);
function editILD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str ='** search module: ILD text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.ILD = ...
        text_update(handles.editILD, handles.sliderILD, handles.h2.search.limits.ILD);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderRatt_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Ratt slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.Ratt = ...
        slider_update(handles.sliderRatt, handles.editRatt);
    guidata(hObject, handles);
function editRatt_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Ratt text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.Ratt = ...
        text_update(handles.editRatt, handles.sliderRatt, handles.h2.search.limits.Ratt);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderABI_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: ABI slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.ABI = ...
        slider_update(handles.sliderABI, handles.editABI);
	guidata(hObject, handles);
function editABI_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: ABI text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.ABI = ...
        text_update(handles.editABI, handles.sliderABI, handles.h2.search.limits.ABI);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderBC_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: BC slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.BC = ...
        slider_update(handles.sliderBC, handles.editBC);
	guidata(hObject, handles);
function editBC_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: BC text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.BC = ...
        text_update(handles.editBC, handles.sliderBC, handles.h2.search.limits.BC);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderITD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: ITD slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.ITD = ...
        slider_update(handles.sliderITD, handles.editITD);
	guidata(hObject, handles);
function editITD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: ITD text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.ITD = ...
        text_update(handles.editITD, handles.sliderITD, handles.h2.search.limits.ITD);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for SEARCH controls --- stimulus type and frequency settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function radioSearchStim_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: stimulus type changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
    % hSelected = get(hObject,'SelectedObject'); % for later matlab versions
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
        case 'radioSearchStimsAM'
            disp('sAM selected')
            handles.h2.search.stimtype = 'SAM'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
    end
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    guidata(hObject, handles);
    HPSearch2_updateUI(handles,'SEARCH:FREQ');
%--------------------------------------------------------------------------
function sliderFreq_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Freq slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.Freq = ...
        slider_update(handles.sliderFreq, handles.editFreq);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
	guidata(hObject, handles);
function editFreq_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Freq text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.Freq = ...
        text_update(handles.editFreq, handles.sliderFreq, handles.h2.search.limits.Freq);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderBW_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: BW slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.BW = ...
        slider_update(handles.sliderBW, handles.editBW);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
	guidata(hObject, handles);
function editBW_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: BW text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.BW = ...
        text_update(handles.editBW, handles.sliderBW, handles.h2.search.limits.BW);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editFmax_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Fmax text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
	handles.h2.search.Fmax = tmp;
    [f,bw] = guiFBWupdate(handles.h2.search.Fmax, handles.h2.search.Fmin, ...
        handles.h2.search.stimtype, handles);
    handles.h2.search.Freq = f;
    handles.h2.search.BW = bw;
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function editFmin_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: Fmin text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
	handles.h2.search.Fmin = tmp;
    [f,bw] = guiFBWupdate(handles.h2.search.Fmax, handles.h2.search.Fmin, ...
        handles.h2.search.stimtype, handles);
    handles.h2.search.Freq = f;
    handles.h2.search.BW = bw;
	guidata(hObject, handles);
%--------------------------------------------------------------------------
% auxiliary function for updating Fmin and Fmax from F and BW
function [minF, maxF] = guiFminmaxUpdate(F,BW,lim,type,handles)
    type = upper(type);
    if strcmp(type,'NOISE') || strcmp(type,'SAM')
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
    else % 'TONE'
        maxF = F;
        minF = F;
    end
    update_ui_str(handles.editFmax, maxF);
	update_ui_str(handles.editFmin, minF);
%--------------------------------------------------------------------------
% auxiliary function for updating F and BW from Fmin and Fmax
function [F, BW] = guiFBWupdate(Fmax,Fmin,type,handles)
    F = round((Fmax+Fmin)/2);
    type = upper(type);
    if strcmp(type,'NOISE') || strcmp(type,'SAM')
        BW = Fmax-Fmin;  
    else % note: when 'TONE' is selected, Fmax and Fmin should be disabled
        BW = 0;
    end 
    update_ui_val(handles.sliderFreq, F);
    update_ui_str(handles.editFreq, F);
    update_ui_val(handles.sliderBW, BW);
    update_ui_str(handles.editBW, BW);
%--------------------------------------------------------------------------
function slidersAMp_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: sAM percent slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.sAMp = ...
        slider_update(handles.slidersAMp, handles.editsAMp);
	guidata(hObject, handles);
function editsAMp_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: sAM percent text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.sAMp = ...
        text_update(handles.editsAMp, handles.slidersAMp, handles.h2.search.limits.sAMp);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function slidersAMf_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: sAM frequency slider changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.search.sAMf = ...
        slider_update(handles.slidersAMf, handles.editsAMf);
	guidata(hObject, handles);
function editsAMf_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** search module: sAM frequency text changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.search.sAMf = ...
        text_update(handles.editsAMf, handles.slidersAMf, handles.h2.search.limits.sAMf);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings buttons callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveSettings_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** settings: save settings clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
	[fname, fpath] = ...
        uiputfile('*_HP2settings.mat', 'Save HPSearch2 settings file...');
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
%--------------------------------------------------------------------------
function buttonLoadSettings_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** settings: load settings clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
	[fname, fpath] = ...
        uigetfile('*_HP2settings.mat', 'Load HPSearch2 settings file...');
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
    HPSearch2_updateUI(handles,'SEARCH');
    HPSearch2_updateUI(handles,'STIMULUS');
    HPSearch2_updateUI(handles,'TDT');
    HPSearch2_updateUI(handles,'CHANNELS');
    HPSearch2_updateUI(handles,'ANALYSIS');
    HPSearch2_updateUI(handles,'CURVE');
    HPSearch2_updateUI(handles,'CLICK');
    HPSearch2_updateUI(handles,'PLOTS');
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CAL button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonLoadCALL_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** calibration settings: Load CAL L clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
	[fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load Cal data for LEFT earphone...');
	if fname == 0 % return if user hits CANCEL button 
		disp('loading cancelled...');
		return;
    end
    disp(['Loading LEFT earphone calibration data from ' fname])
    try % loading calibration file
		tmpcal = HPSearch2_loadcal(fullfile(fpath, fname), 'L'); 
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
%--------------------------------------------------------------------------
function buttonLoadCALR_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** calibration settings: Load CAL R clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
	[fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load Cal data for RIGHT earphone...');
	if fname == 0 % return if user hits CANCEL button 
		disp('loading cancelled...');
		return;
    end
    disp(['Loading RIGHT earphone calibration data from ' fname])
    try % loading calibration file
		tmpcal = HPSearch2_loadcal(fullfile(fpath, fname), 'R'); 
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
%--------------------------------------------------------------------------
function buttonPlotCAL_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** calibration settings: Plot CAL clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    calinfo = handles.h2.calinfo;
    if ~calinfo.loadedR && ~calinfo.loadedL  % neither L nor R is loaded
        disp('no cal files loaded');
        return;
    end
    HPSearch2_plotcal(handles.h2.calinfo.loadedL, handles.h2.caldataL, ...
                      handles.h2.calinfo.loadedR, handles.h2.caldataR);
%--------------------------------------------------------------------------
function buttonDeleteCal_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** calibration settings: Delete CAL clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.calinfo = HPSearch2_init('CALINFO'); % reset filenames and flags
    handles.h2.caldataL = [];
    handles.h2.caldataR = [];
   	update_ui_str(handles.textCALfileL, 'unloaded');
   	update_ui_str(handles.textCALfileR, 'unloaded');
    handles.h2.search.LeftON = 0;
    handles.h2.search.RightON = 0;
    handles.h2.search.limits.Freq = handles.h2.search.limits.defaultFreq; % reset to default
    HPSearch2_updateUI(handles,'SEARCH:ATTEN');
    % disabling Plot CAL button and LEFT ON and Right ON checkboxes
    disable_ui(handles.buttonPlotCAL);
    disable_ui(handles.checkLeftON);
    disable_ui(handles.checkRightON);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Animal/Experiment settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editDate_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: date changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    disp('Sorry, the Date field is not editable.');
    disp('Please change the clock of your computer, if you wish to change dates');
	update_ui_str(hObject, handles.h2.animal.Date);
   	guidata(hObject, handles);
%--------------------------------------------------------------------------
function editAnimal_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: animal# changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.Animal = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editUnit_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: unit# changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.Unit = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editRec_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: rec# changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.Rec = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editPen_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: penetration# changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.Pen = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editAP_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: AP changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.AP = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editML_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: ML changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.ML = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editDepth_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** experiment data settings: depth changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
	handles.h2.animal.Depth = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editISI_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** stimulus settings: ISI changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.ISI)	% check limits
		handles.h2.stimulus.ISI = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.ISI);
    end
%--------------------------------------------------------------------------
function editDuration_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** stimulus settings: duration changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.Duration)	% check limits
		handles.h2.stimulus.Duration = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.Duration);
    end
%--------------------------------------------------------------------------
function editDelay_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** stimulus settings: delay changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.Delay)	% check limits
		handles.h2.stimulus.Delay = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.Delay);
    end
%--------------------------------------------------------------------------
function editRamp_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** stimulus settings: ramp changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.stimulus.limits.Ramp)	% check limits
		handles.h2.stimulus.Ramp = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.stimulus.Ramp);
    end
%--------------------------------------------------------------------------
function checkRadVary_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** stimulus settings: radvary clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.stimulus.RadVary = read_ui_val(hObject); 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
function checkFrozenStim_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** stimulus settings: frozen stim clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.stimulus.Frozen = read_ui_val(hObject); 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editAcqDuration_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT settings: acq duration changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.AcqDuration)	% check limits
		handles.h2.tdt.AcqDuration = tmp;
        handles.h2.tdt.SweepPeriod = tmp + 10;
		update_ui_str(handles.editSweepPeriod, handles.h2.tdt.SweepPeriod);
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.AcqDuration);
    end
%--------------------------------------------------------------------------
function editSweepPeriod_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT settings: sweep period changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    disp('Sorry, Sweep Period is not editable.');
    disp('Change AcqDuration instead.'); 
    disp('SweepPeriod is determined as AcqDuration + 10.');    
	update_ui_str(hObject, handles.h2.tdt.SweepPeriod);
   	guidata(hObject, handles);
%--------------------------------------------------------------------------
function editTTLPulseDur_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT settings: TTL pulse dur changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.TTLPulseDur)	% check limits
		handles.h2.tdt.TTLPulseDur = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.TTLPulseDur);
    end
%--------------------------------------------------------------------------
function editCircuitGain_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT settings: circuit gain changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.CircuitGain)	% check limits
		handles.h2.tdt.CircuitGain = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.CircuitGain);
    end
%--------------------------------------------------------------------------
function editHPFreq_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT settings: HP freq changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.HPFreq)	% check limits
		handles.h2.tdt.HPFreq = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.HPFreq);
    end
%--------------------------------------------------------------------------
function editLPFreq_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** TDT settings: LP freq changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.tdt.limits.LPFreq)	% check limits
		handles.h2.tdt.LPFreq = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.tdt.LPFreq);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I/O channel settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editInput_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** I/O channel settings: input channel changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.channels.InputChannel = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editOutputL_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** I/O channel settings: output channel L changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.channels.OutputChannelL = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editOutputR_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** I/O channel settings: output channel R changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.channels.OutputChannelR = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spike Analysis settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editWindowWidth_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** spike analysis settings: window width changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.WindowWidth)	% check limits
		handles.h2.analysis.WindowWidth = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.WindowWidth);
    end
%--------------------------------------------------------------------------
function editStartTime_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** spike analysis settings: start time changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.StartTime)	% check limits
		handles.h2.analysis.StartTime = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.StartTime);
    end
%--------------------------------------------------------------------------
function editEndTime_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** spike analysis settings: end time changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.EndTime)	% check limits
		handles.h2.analysis.EndTime = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.EndTime);
    end
%--------------------------------------------------------------------------
function editThres_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** spike analysis settings: threshold changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.ThresSD)	% check limits
		handles.h2.analysis.ThresSD = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.ThresSD);
    end
%--------------------------------------------------------------------------
function editRaster_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** spike analysis settings: Raster# changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
	if checklim(tmp, handles.h2.analysis.limits.Raster)	% check limits
		handles.h2.analysis.Raster = tmp;
        guidata(hObject, handles);
    else % resetting to old value
		update_ui_str(hObject, handles.h2.analysis.Raster);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonClearPlot_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clear plot';
        disp(str); set(handles.textMessage, 'String', str);
    end
    cla(handles.axesUpclose);
    cla(handles.axesResp);
    cla(handles.axesRaster);
    cla(handles.axesPSTH);
    cla(handles.axesISIH);
%--------------------------------------------------------------------------
function editRate_Callback(hObject, eventdata, handles)
% This editbox is only for showing spike rates.
% User cannot edit this box.
% 
%--------------------------------------------------------------------------
function radioPlot_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** plot setting changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
  % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioShowAll'
            disp('Plot ALL')
            handles.h2.plots = HPSearch2_init('PLOTS:ALL');
        case 'radioShowResp'
            disp('Plot Response Only')
            handles.h2.plots = HPSearch2_init('PLOTS:RESP');
        case 'radioShowRU'
            disp('Plot Response + Upclose')
            handles.h2.plots = HPSearch2_init('PLOTS:REUP');
        case 'radioShowNone'
            disp('Plot OFF')
            handles.h2.plots = HPSearch2_init('PLOTS:NONE');
        end
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkboxes, editboxes and radio buttons for Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editCurveReps_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: #Reps changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checkCurveLimits(tmp, handles.h2.stimulus.limits.Reps) % check limits
        handles.h2.paramCurrent.Reps = tmp;
        HPSearch2_storecurveparams; % save current parameters 
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('# Reps out of bounds [%d %d]', ... 
             handles.h2.stimulus.limits.Reps(1), handles.h2.stimulus.limits.Reps(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.Reps);
    end
%--------------------------------------------------------------------------
function editCurveITD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: ITD changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'ITD')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.ITD); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ITD(1), handles.h2.search.limits.ITD(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.ITDstring);
    end
%--------------------------------------------------------------------------
function editCurveILD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: ILD changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'ILD')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.ILD); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('ILD range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ILD(1), handles.h2.search.limits.ILD(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.ILDstring);
    end
%--------------------------------------------------------------------------
function editCurveABI_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: ABI changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'ABI')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.ABI); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('ABI range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ABI(1), handles.h2.search.limits.ABI(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.ABIstring);
    end
%--------------------------------------------------------------------------
function editCurveFreq_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: Freq changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'FREQ')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.Freq); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('Freq range out of bounds [%d %d]', ... 
             handles.h2.search.limits.Freq(1), handles.h2.search.limits.Freq(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.Freqstring);
    end
%--------------------------------------------------------------------------
function editCurveBC_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: BC changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'BC')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.BC); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('BC range out of bounds [%d %d]', ... 
             handles.h2.search.limits.BC(1), handles.h2.search.limits.BC(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.BCstring);
    end
%--------------------------------------------------------------------------
function editCurvesAMp_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: sAM percent changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'SAMP')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.sAMp); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('sAM percent range out of bounds [%d %d]', ... 
             handles.h2.search.limits.sAMp(1), handles.h2.search.limits.sAMp(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.sAMpstring);
    end
%--------------------------------------------------------------------------
function editCurvesAMf_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: sAM freq changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%        if strcmp(upper(handles.h2.paramCurrent.curvetype), 'SAMP')        
%            handles.h2.paramCurrent.Trials = length(handles.h2.paramCurrent.sAMf); 
%        end
        HPSearch2_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        disp(sprintf('sAM freq range out of bounds [%d %d]', ... 
             handles.h2.search.limits.sAMf(1), handles.h2.search.limits.sAMf(2)));
        update_ui_str(hObject, handles.h2.paramCurrent.sAMfstring);
    end
%--------------------------------------------------------------------------
function checkCurveSpont_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: Spont checkbox clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.curve.Spont = read_ui_val(hObject); 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
function checkCurveTemp_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: Temp checkbox clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.curve.Temp = read_ui_val(hObject); 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
function checkCurveSaveStim_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: SaveStim checkbox clicked';
        disp(str); set(handles.textMessage, 'String', str);
    end
    handles.h2.curve.SaveStim = read_ui_val(hObject); 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
function radioCurveType_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: curve type changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
  % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveTypeBF'
            disp('BF curve selected')
            handles.h2.paramCurrent = handles.h2.paramBF;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypeITD'
            disp('ITD curve selected')
            handles.h2.paramCurrent = handles.h2.paramITD;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypeILD'
            disp('ILD curve selected')
            handles.h2.paramCurrent = handles.h2.paramILD;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypeABI'
            disp('ABI curve selected')
            handles.h2.paramCurrent = handles.h2.paramABI;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypeBC'
            disp('BC curve selected')
            handles.h2.paramCurrent = handles.h2.paramBC;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypesAMp'
            disp('sAM percent curve selected')
            handles.h2.paramCurrent = handles.h2.paramsAMp;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypesAMf'
            disp('sAM freq curve selected')
            handles.h2.paramCurrent = handles.h2.paramsAMf;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypeCF'
            disp('CF curve selected')
            handles.h2.paramCurrent = handles.h2.paramCF;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypeCD'
            disp('CD curve selected')
            handles.h2.paramCurrent = handles.h2.paramCD;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
        case 'radioCurveTypePH'
            disp('Phase Histogram selected')
            handles.h2.paramCurrent = handles.h2.paramPH;
            HPSearch2_updateUI(handles,'CURVE');
            guidata(hObject, handles);
    end
%--------------------------------------------------------------------------
function radioCurveStim_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: stimulus type changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
  % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveStimNoise'
            disp('noise selected')
            handles.h2.curve.stimtype = 'NOISE'; 
            guidata(hObject, handles);
        case 'radioCurveStimTone'
            disp('tone selected')
            handles.h2.curve.stimtype = 'TONE'; 
            guidata(hObject, handles);
        end
%--------------------------------------------------------------------------
function radioCurveSide_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** curves module: stimulus side changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
  % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveSideBoth'
            disp('binaural selected')
            handles.h2.curve.side = 'BOTH'; 
            guidata(hObject, handles);
        case 'radioCurveSideLeft'
            disp('left selected')
            handles.h2.curve.side = 'LEFT'; 
            guidata(hObject, handles);
        case 'radioCurveSideRight'
            disp('right selected')
            handles.h2.curve.side = 'RIGHT'; 
            guidata(hObject, handles);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkboxes, editboxes and radio buttons for Clicks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editClickSamples_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: #Samples changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Samples) % check limits
        tmp = ceil(tmp/2)*2; %% round to even number
        update_ui_str(hObject, tmp); %% update edit box 
        handles.h2.click.Samples = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Samples);
    end
%--------------------------------------------------------------------------
function editClickReps_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: #Reps changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Reps) % check limits
        handles.h2.click.Reps = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Reps);
    end
%--------------------------------------------------------------------------
function editClickITD_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: ITD changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
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
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%+++++ need to figure out if we need the Trials variable ++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%        handles.h2.click.Trials = length(handles.h2.click.ITD);
        guidata(hObject, handles);
    else % if out of limits
        disp(sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.click.limits.ITD(1), handles.h2.click.limits.ITD(2)));
        update_ui_str(hObject, handles.h2.click.ITDstring);
    end
%--------------------------------------------------------------------------
function editClickLatten_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: Latten changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Latten) % check limits
        handles.h2.click.Latten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Latten);
    end
%--------------------------------------------------------------------------
function editClickRatten_Callback(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: Ratten changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Ratten) % check limits
        handles.h2.click.Ratten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Ratten);
    end
%--------------------------------------------------------------------------
function radioClickType_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: stimulus type changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
  % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioClickTypeCond'
            disp('condensed click selected')
            handles.h2.click.clicktype = 'COND'; 
            guidata(hObject, handles);
        case 'radioClickTypeRare'
            disp('rare click selected')
            handles.h2.click.clicktype = 'RARE'; 
            guidata(hObject, handles);
    end
%--------------------------------------------------------------------------
function radioClickSide_SelectionChangeFcn(hObject, eventdata, handles)
    if(handles.DEBUG) % debug mode
        str = '** clicks module: stimulus side changed';
        disp(str); set(handles.textMessage, 'String', str);
    end
    hSelected = hObject; % for R2007a
  % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioClickSideBoth'
            disp('binaural click selected')
            handles.h2.click.side = 'BOTH'; 
            guidata(hObject, handles);
        case 'radioClickSideLeft'
            disp('left click selected')
            handles.h2.click.side = 'LEFT'; 
            guidata(hObject, handles);
        case 'radioClickSideRight'
            disp('right click selected')
            handles.h2.click.side = 'RIGHT'; 
            guidata(hObject, handles);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function popupTDT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editITD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderITD_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editLatt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderLatt_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editILD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderILD_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editRatt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderRatt_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editABI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderABI_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editBC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderBC_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderFreq_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editBW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sliderBW_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editFmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editsAMp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slidersAMp_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editsAMf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slidersAMf_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%--------------------------------------------------------------------------
function editAcqDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSweepPeriod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editTTLPulseDur_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCircuitGain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editHPFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editLPFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editInput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editOutputL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editOutputR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editDate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAnimal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editUnit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editPen_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editML_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDepth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editISI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDelay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRamp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editWindowWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editStartTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editEndTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editThres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editRaster_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editCurveReps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurveITD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurveILD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurveABI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurveFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurveBC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurvesAMp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCurvesAMf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
function editClickReps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editClickSamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editClickITD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editClickLatten_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editClickRatten_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------

