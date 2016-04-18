function varargout = FOCHS(varargin)
%--------------------------------------------------------------------------
% 
% FOur-CHannel recording System for auditory neurophysiology 
%   based on HPSearch and HPSearch2 
%
%--------------------------------------------------------------------------

% Last Modified by GUIDE v2.5 19-May-2012 02:25:39

%--------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag 
%   ashida@umd.edu
%   sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Original Version (HPSearch): 2009-2011 by SJS
% Upgraded Version (HPSearch2): 2011-2012 by GA
% Four-channel Input Version (FOCHS): 2012 by GA  
%--------------------------------------------------------------------------
% ** Important Notes ** (Nov 2011, GA)
%   Parameters used in FOCHS/HPSearch2 are stored under the handles.h2 
%   structure, while parameters used in HPSearch are stored directly 
%   under handles 
%
% ** Important Notes ** (Feb 2012, GA)
%   This FOCHS.m file handles only GUI-related issues. 
%   Most parts of recording and other components are delegated to 
%   corresponding subroutines (see below for a list). 
%
 
%--------------------------------------------------------------------------
% [ Major Subroutines --- needs updating ] (info added by GA, Feb 2012)
% * FOCHS_Opening.m     : called from FOCHS_OpeningFcn
% * FOCHS_Closing.m     : called from CloseRequestFcn
% * FOCHS_TDTopen.m     : called from buttonTDTenable_Callback
% * FOCHS_TDTclose.m    : called from buttonTDTenable_Callback
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
                   'gui_OpeningFcn', @FOCHS_OpeningFcn, ...
                   'gui_OutputFcn',  @FOCHS_OutputFcn, ...
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
% --- Executes just before the GUI is made visible. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function FOCHS_OpeningFcn(hObject, eventdata, handles, varargin)
    % debug mode on
    handles.DEBUG = 1;  % 1:debug mode; 0:normal mode 
    guidata(hObject, handles);
    % display message 
    str = '** FOCHS: opening function called';
    set(handles.textMessage, 'String', str);
    disp(str);
    % if debug mode, enable ShowVal button
    if(handles.DEBUG) 
        enable_ui(handles.buttonShowVal);
        set(handles.buttonShowVal, 'Visible', 'on');
    end
    % go to Opening subroutine to initialize params etc.
    FOCHS_Opening;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function varargout = FOCHS_OutputFcn(hObject, eventdata, handles) 
    % display message 
    str = '** FOCHS: output function called';
    set(handles.textMessage, 'String', str);
    disp(str);
    % set output to command window
    varargout{1} = hObject;
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Cleaning up before closing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function CloseRequestFcn(hObject, eventdata, handles)
    % display message 
    str = '** FOCHS: closing function called';
    set(handles.textMessage, 'String', str);
    disp(str);
    % go to Closing subroutine to close TDT etc. 
    FOCHS_Closing; 
    % delete GUI
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
    % display message 
    str = '** Call Plot button pressed';
    set(handles.textMessage, 'String', str);
    % call plotting scripts
    FOCHS_simpleView; 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup menu for selecting TDT hardware 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function popupTDT_Callback(hObject, eventdata, handles)
    % display message
    str = '** TDT hardware selection changed';
    set(handles.textMessage, 'String', str);
    % get selected item 
    tdtStrings = read_ui_str(hObject);  % list of strings
    selectedVal = read_ui_val(hObject); % selected item number
    selectedStr = upper(tdtStrings{selectedVal}); % selected item
    switch selectedStr 
        case 'NO_TDT'
            str = 'Test run mode: No TDT hardware used.';
%            handles.WithoutTDT = 1; 
        case 'RX8_50K'
            str = 'RX8 selected. Sampling rate: 50 kHz';
%            handles.WithoutTDT = 0; 
        case 'RZ6 + RZ5D'
            str = 'RZ6 + RZ5D selected. Input: 50 kHz';
%            handles.WithoutTDT = 0; 
    end
    % display message
    set(handles.textMessage, 'String', str);
    % update handles.h2.config according to the selected TDT hardware
    handles.TDThardware = selectedStr; 
    handles.h2.config = FOCHS_config(handles.TDThardware);
    handles.h2.config.TDTLOCKFILE = handles.TDTLOCKFILE;
    % save handles structure 
    guidata(hObject, handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enabling (or disabling) TDT hardware 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonTDTenable_Callback(hObject, eventdata, handles)
    % display message
    str = '** TDT Enable/Disable button pressed';
    set(handles.textMessage, 'String', str);
    % define colors
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red 
    INITCOLOR   = [0.0 0.0 0.5];  % Dark Blue 
    ENABLECOLOR = [0.0 0.5 0.0];  % Dark Green 

    % get the state of the buttons
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
    if buttonState % User pressed button to enable TDT Circuits
        % update button UI
        set(handles.buttonTDTenable, 'ForegroundColor', INITCOLOR);
        update_ui_str(hObject, 'initializing')

        % attempt to open TDT hardware
        [ tmphandles, tmpflag ] = FOCHS_TDTopen(handles.h2.config);

        if tmpflag > 0  % TDT hardware is now running 
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
            % show error message
            str = 'Failed to start TDT';
            set(handles.textMessage, 'String', str);
            errordlg(str, 'TDT initialization error');
            % update UI
            update_ui_val(hObject, 0);
            set(hObject, 'ForegroundColor', ENABLECOLOR);
            update_ui_str(hObject, 'TDT Enable');
        else % tmpflag==0, TDT is not initialized
            % show error message
            str = 'TDT is not initialized'; 
            set(handles.textMessage, 'String', str);
            errordlg(str, 'TDT initialization error');
            % update UI
            update_ui_val(hObject, 0);
            set(hObject, 'ForegroundColor', ENABLECOLOR);
            update_ui_str(hObject, 'TDT Enable');
        end

    else % buttonState == 0: User pressed button to turn off TDT Circuits
        % update button UI
        set(handles.buttonTDTenable, 'ForegroundColor', INITCOLOR);
        update_ui_str(hObject, 'disabling')

        % attempt to close TDT hardware
        [ tmphandles, tmpflag ] = FOCHS_TDTclose(...
            handles.h2.config, handles.indev, handles.outdev, ...
            handles.zBUS, handles.PA5L, handles.PA5R);

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
            % show error message
            str = 'Failed to stop TDT';
            set(handles.textMessage, 'String', str);
            errordlg(str, 'TDT termination error');
            % update UI
            set(hObject, 'ForegroundColor', DISABLECOLOR);
            update_ui_str(hObject, 'TDT Disable')
        end

    end % end of "if buttonState"
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH button callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% When user clicks the SEARCH button, the value of the button is toggled; 
% If the button is "hi" (value == 1), the user wants to start the run.
% If the button is "lo" (value == 0), the user wants to stop the run.  
% If start requested, also need to make sure the TDT is enabled. (SJS)
%--------------------------------------------------------------------------
function buttonSearch_Callback(hObject, eventdata, handles)
    % display message
    str = '** SEARCH button pressed';
    set(handles.textMessage, 'String', str);
    % define colors
    DISABLECOLOR =[0.5 0.0 0.0];  % Dark Red
    ENABLECOLOR = [0.0 0.5 0.0];  % Dark Green    

    % get the states of the button and TDTINIT 
    buttonState = read_ui_val(hObject); % 1=ON; 0=OFF
    load(handles.h2.config.TDTLOCKFILE); % loading TDTINIT 
    %-----------------------------------------------------
    % buttonState=0 & TDTINIT=0 : (this should not happen: Search button is disabled before TDT is initialized)
    % buttonState=1 & TDTINIT=0 : need to start TDT before starting stimulus
    % buttonState=0 & TDTINIT=1 : stop search stimulus
    % buttonState=1 & TDTINIT=1 : start search stimulus
    %-----------------------------------------------------

    % if user wants to start, check if TDT hardware has been initialized
    if buttonState && ~TDTINIT
        % display message
        str = 'TDT Hardware is not initialized!! Cancelling search...';
        errordlg(str, 'Search routine error'); 
        set(handles.textMessage, 'String', str);
        % update UI
        update_ui_val(hObject, 0);
        update_ui_str(hObject, 'Search');
        set(hObject, 'ForegroundColor', ENABLECOLOR);

    % if buttonState is 0 and TDT hardware is running, then stop stimulus
    % Note: loop in FOCHS_Search.m finishes when "read_ui_val(hObject)=0"
    elseif ~buttonState && TDTINIT
        % display message
        str = 'Ending search stimuli...';
        set(handles.textMessage, 'String', str);
        % update UI and enable other buttons
        update_ui_str(hObject, 'Search')
        set(hObject, 'ForegroundColor', ENABLECOLOR);
        FOCHS_enableUIs(handles, 'ENABLE');

    % if buttonState is 1 and TDT is running, then start stimulus
    % stimulus will remain ON, while "read_ui_val(hObject)=1"
    else 
        % display message
        str = 'Starting search stimuli...';
        set(handles.textMessage, 'String', str);
        % update UI and disable other buttons
        update_ui_str(hObject, 'Stop');
        set(hObject, 'ForegroundColor', DISABLECOLOR);
        FOCHS_enableUIs(handles, 'DISABLE'); 
        % save handles structure 
        guidata(hObject, handles);
        % go to main part of the Search routine 
        FOCHS_Search; 
    end 

    % save handles structure 
    guidata(hObject,handles); 
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Curve button callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonCurve_Callback(hObject, eventdata, handles)
    % display message
    str = '** CURVE button pressed';
    set(handles.textMessage, 'String', str);

    % updating UI and disabling other buttons
    FOCHS_enableUIs(handles, 'DISABLE');
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
        str = 'Curve button was hit even though it should have been disabled';
        set(handles.textMessage, 'String', str);
        errordlg(str, 'Curve routine error');
        return;
    end

    % if user wants to start, check if TDT hardware has been initialized
    if ~TDTINIT
        str = 'TDT Hardware is not initialized!! Cancelling Curve...'; 
        set(handles.textMessage, 'String', str);
        errordlg(str, 'TDT error');
        CurveSuccessFlag = -2; % failed 
    end

    % user wants to run curve, TDT hardware is running, so all is well
    if CurveSuccessFlag == 0  
        % display message
        str = 'Starting Curve...';
        set(handles.textMessage, 'String', str);
        % update button text
        update_ui_str(hObject, 'Running');
        % save handles structure 
        guidata(hObject, handles);
        % go to main part of Curve
        FOCHS_Curve; 
        % update button text
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
    handles.h2.animal.Date = TytoLogy2_datetime('date');
    handles.h2.animal.Time = TytoLogy2_datetime('time');
    FOCHS_updateUI(handles, 'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    FOCHS_enableUIs(handles, 'ENABLE');
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
    % display message
    str = '** CLICK button pressed';
    set(handles.textMessage, 'String', str);

    % updating UI and disabling other buttons
    FOCHS_enableUIs(handles, 'DISABLE');
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
        str = 'Click button was hit even though it should have been disabled';
        set(handles.textMessage, 'String', str);
        errordlg(str, 'Click routine error');
        return;
    end

    % if user wants to start, check if TDT hardware has been initialized
    if ~TDTINIT
        str = 'TDT Hardware is not initialized!! Cancelling Click...'; 
        set(handles.textMessage, 'String', str);
        errordlg(str, 'TDT error');
        ClickSuccessFlag = -2; % failed 
    end

    % user wants to run clicks, TDT hardware is running, so all is well
    if ClickSuccessFlag == 0
        % display message
        str = 'Starting Click...';
        set(handles.textMessage, 'String', str);
        % update button text
        update_ui_str(hObject, 'Running');
        % save handles structure 
        guidata(hObject, handles);
        % go to main part of Curve
        FOCHS_Click; 
        % update button text
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
    handles.h2.animal.Date = TytoLogy2_datetime('date');
    handles.h2.animal.Time = TytoLogy2_datetime('time');
    FOCHS_updateUI(handles, 'ANIMAL');

    % updating UI and enabling buttons
    update_ui_val(hObject, 0);
    FOCHS_enableUIs(handles, 'ENABLE');
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
    % display message
    str = 'ABORT button pressed';
    set(handles.textMessage, 'String', str);
    % disable ui --- should be re-enabled in other (Curve or Click) routines 
    disable_ui(hObject); 
    % save handles structure
    guidata(hObject, handles);    
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for SEARCH controls --- L/R, attenuation and ITD settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function checkLeftON_Callback(hObject, eventdata, handles)
    % read button state
    handles.h2.search.LeftON = read_ui_val(hObject);
    if handles.h2.search.LeftON 
        % check if calibration file has been loaded
        if ~handles.h2.calinfo.loadedL 
            str = 'Calibration file for LEFT must be loaded!!'; 
            set(handles.textMessage, 'String', str);
            update_ui_val(hObject, 0); % reset checkbox state
            handles.h2.search.LeftON = 0;
            update_ui_val(handles.checkLeftON, handles.h2.search.LeftON);
            guidata(hObject,handles);
            return;
        end
        str = 'Left channel ON';
    else 
        str = 'Left channel OFF';
    end 
    % save handles structure
    guidata(hObject, handles); 
    % display message    
    set(handles.textMessage, 'String', str);
    % update UI
    FOCHS_updateUI(handles, 'SEARCH:ATTEN');
%--------------------------------------------------------------------------
function checkRightON_Callback(hObject, eventdata, handles)
    % read button state
    handles.h2.search.RightON = read_ui_val(hObject);
    if handles.h2.search.RightON 
        % check if calibration file has been loaded
        if ~handles.h2.calinfo.loadedR 
            str = 'Error: Calibration file for RIGHT must be loaded!!';
            set(handles.textMessage, 'String', str);
            update_ui_val(hObject, 0); % reset checkbox state
            handles.h2.search.RightON = 0;
            update_ui_val(handles.checkRightON, handles.h2.search.RightON);
            guidata(hObject,handles);
            return;
        end
        str = 'Right channel ON';
    else
        str = 'Right channel OFF';
    end 
    % save handles structure
    guidata(hObject, handles); 
    % display message    
    set(handles.textMessage, 'String', str);
    % update UI
    FOCHS_updateUI(handles, 'SEARCH:ATTEN');
%--------------------------------------------------------------------------
function sliderLatt_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Latt slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox 
    handles.h2.search.Latt = ...
        slider_update(handles.sliderLatt, handles.editLatt);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editLatt_Callback(hObject, eventdata, handles)
    % display message
    str  = '** search module: Latt text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.Latt = ...
        text_update(handles.editLatt, handles.sliderLatt, handles.h2.search.limits.Latt);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderILD_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: ILD slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox 
    handles.h2.search.ILD = ...
        slider_update(handles.sliderILD, handles.editILD);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editILD_Callback(hObject, eventdata, handles)
    % display message
    str ='** search module: ILD text changed';
    set(handles.textMessage, 'String', str);
    % update slider 
    handles.h2.search.ILD = ...
        text_update(handles.editILD, handles.sliderILD, handles.h2.search.limits.ILD);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderRatt_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Ratt slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox
    handles.h2.search.Ratt = ...
        slider_update(handles.sliderRatt, handles.editRatt);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editRatt_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Ratt text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.Ratt = ...
        text_update(handles.editRatt, handles.sliderRatt, handles.h2.search.limits.Ratt);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderABI_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: ABI slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox
    handles.h2.search.ABI = ...
        slider_update(handles.sliderABI, handles.editABI);
    % save handles structure
    guidata(hObject, handles);
function editABI_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: ABI text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.ABI = ...
        text_update(handles.editABI, handles.sliderABI, handles.h2.search.limits.ABI);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderBC_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: BC slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox 
    handles.h2.search.BC = ...
        slider_update(handles.sliderBC, handles.editBC);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editBC_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: BC text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.BC = ...
        text_update(handles.editBC, handles.sliderBC, handles.h2.search.limits.BC);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderITD_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: ITD slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox
    handles.h2.search.ITD = ...
        slider_update(handles.sliderITD, handles.editITD);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editITD_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: ITD text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.ITD = ...
        text_update(handles.editITD, handles.sliderITD, handles.h2.search.limits.ITD);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for SEARCH controls --- stimulus type and frequency settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function radioSearchStim_SelectionChangeFcn(hObject, eventdata, handles)
    % get selected val 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioSearchStimNoise'
            handles.h2.search.stimtype = 'NOISE'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
            str = '** search module: noise selected';
        case 'radioSearchStimTone'
            handles.h2.search.stimtype = 'TONE'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
            str = '** search module: tone selected';
        case 'radioSearchStimsAM'
            handles.h2.search.stimtype = 'SAM'; 
            [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
                handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles); 
            str = '** search module: sAM selected';
    end
    % set Fmin and Fmax
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    % save handles structure
    guidata(hObject, handles);
    % display message
    set(handles.textMessage, 'String', str);
    % update UI
    FOCHS_updateUI(handles, 'SEARCH:FREQ');
%--------------------------------------------------------------------------
function sliderFreq_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Freq slider changed';
    set(handles.textMessage, 'String', str);
    % update other editboxes and sliders 
    handles.h2.search.Freq = ...
        slider_update(handles.sliderFreq, handles.editFreq);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editFreq_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Freq text changed';
    set(handles.textMessage, 'String', str);
    % update other editboxes and sliders 
    handles.h2.search.Freq = ...
        text_update(handles.editFreq, handles.sliderFreq, handles.h2.search.limits.Freq);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function sliderBW_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: BW slider changed';
    set(handles.textMessage, 'String', str);
    % update other editboxes and sliders 
    handles.h2.search.BW = ...
        slider_update(handles.sliderBW, handles.editBW);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editBW_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: BW text changed';
    set(handles.textMessage, 'String', str);
    % update other editboxes and sliders 
    handles.h2.search.BW = ...
        text_update(handles.editBW, handles.sliderBW, handles.h2.search.limits.BW);
    [minF, maxF] = guiFminmaxUpdate(handles.h2.search.Freq, handles.h2.search.BW, ...
        handles.h2.search.limits.Freq, handles.h2.search.stimtype, handles);
    handles.h2.search.Fmin = minF;
    handles.h2.search.Fmax = maxF;
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editFmax_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Fmax text changed';
    set(handles.textMessage, 'String', str);
    % check limits etc.
    tmp = read_ui_str(hObject, 'n');
    if isnan(tmp)
        str = 'Warning: Fmax in not numeric. Reverting to orginal value'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.search.Fmax);
        return;
    end
    if ~checklim(tmp, handles.h2.search.limits.Freq) 
        str = 'warning: Fmax is out of range. Reverting to orginal value'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.search.Fmax);
        return;
    end
    % update other editboxes and sliders 
    handles.h2.search.Fmax = tmp;
    [f,bw] = guiFBWupdate(handles.h2.search.Fmax, handles.h2.search.Fmin, ...
        handles.h2.search.stimtype, handles);
    handles.h2.search.Freq = f;
    handles.h2.search.BW = bw;
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editFmin_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: Fmin text changed';
    set(handles.textMessage, 'String', str);
    % check limits etc.
    tmp = read_ui_str(hObject, 'n');
    if isnan(tmp)
        str = 'Warning: Fmin in not numeric. Reverting to orginal value'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.search.Fmin);
        return;
    end
    if ~checklim(tmp, handles.h2.search.limits.Freq) 
        str = 'Warning: Fmin is out of range. Reverting to orginal value'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.search.Fmin);
        return;
    end
    % update other editboxes and sliders 
    handles.h2.search.Fmin = tmp;
    [f,bw] = guiFBWupdate(handles.h2.search.Fmax, handles.h2.search.Fmin, ...
        handles.h2.search.stimtype, handles);
    handles.h2.search.Freq = f;
    handles.h2.search.BW = bw;
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function [minF, maxF] = guiFminmaxUpdate(F,BW,lim,type,handles)
% auxiliary function for updating Fmin and Fmax from F and BW
    type = upper(type);
    if strcmp(type,'NOISE') || strcmp(type,'SAM')
        maxF = round(F+BW/2);
        minF = round(F-BW/2);
        if minF < lim(1)
            str = 'Warning: Fmin is too low. Using lowest possible setting';
            set(handles.textMessage, 'String', str);
            minF = lim(1); 
        end
        if maxF > lim(2)
            str = 'Warning: Fmax is too high. Using highest possible setting';
            set(handles.textMessage, 'String', str);
            maxF = lim(2); 
        end
    else % 'TONE'
        maxF = F;
        minF = F;
    end
    update_ui_str(handles.editFmax, maxF);
    update_ui_str(handles.editFmin, minF);
%--------------------------------------------------------------------------
function [F, BW] = guiFBWupdate(Fmax,Fmin,type,handles)
% auxiliary function for updating F and BW from Fmin and Fmax
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
    % display message
    str = '** search module: sAM percent slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox
    handles.h2.search.sAMp = ...
        slider_update(handles.slidersAMp, handles.editsAMp);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editsAMp_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: sAM percent text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.sAMp = ...
        text_update(handles.editsAMp, handles.slidersAMp, handles.h2.search.limits.sAMp);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function slidersAMf_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: sAM frequency slider changed';
    set(handles.textMessage, 'String', str);
    % update editbox
    handles.h2.search.sAMf = ...
        slider_update(handles.slidersAMf, handles.editsAMf);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editsAMf_Callback(hObject, eventdata, handles)
    % display message
    str = '** search module: sAM frequency text changed';
    set(handles.textMessage, 'String', str);
    % update slider
    handles.h2.search.sAMf = ...
        text_update(handles.editsAMf, handles.slidersAMf, handles.h2.search.limits.sAMf);
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings buttons callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonSaveSettings_Callback(hObject, eventdata, handles)
    % display message
    str = '** settings: save settings clicked';
    set(handles.textMessage, 'String', str);
    % get file name 
    [fname, fpath] = ...
        uiputfile('*_FOCHSsettings.mat', 'Save FOCHS settings file...');
    if fname == 0 % return if user hits CANCEL button
        str = 'saving cancelled...';
        set(handles.textMessage, 'String', str);
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
    str = ['Saving settings to ' fname];
    set(handles.textMessage, 'String', str);
    save(fullfile(fpath, fname), '-MAT', 'settingdata');
%--------------------------------------------------------------------------
function buttonLoadSettings_Callback(hObject, eventdata, handles)
    % display message
    str = '** settings: load settings clicked';
    set(handles.textMessage, 'String', str);
    % get file name 
    [fname, fpath] = ...
        uigetfile('*_FOCHSsettings.mat', 'Load FOCHS settings file...');
    if fname == 0 % return if user hits CANCEL button
        str = 'loading cancelled...';
        set(handles.textMessage, 'String', str);
        return;
    end
    % load data
    str = ['Loading settings from ' fname];
    set(handles.textMessage, 'String', str);
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
    % save handles structure
    guidata(hObject, handles);    
    % update GUI according to the loaded data
    FOCHS_updateUI(handles, 'SEARCH');
    FOCHS_updateUI(handles, 'STIMULUS');
    FOCHS_updateUI(handles, 'TDT');
    FOCHS_updateUI(handles, 'CHANNELS');
    FOCHS_updateUI(handles, 'ANALYSIS');
    FOCHS_updateUI(handles, 'CURVE');
    FOCHS_updateUI(handles, 'CLICK');
    FOCHS_updateUI(handles, 'PLOTS');
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CAL button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonLoadCALL_Callback(hObject, eventdata, handles)
    % display message
    str = '** calibration settings: Load CAL L clicked';
    set(handles.textMessage, 'String', str);
    % get file name
    [fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load Cal data for LEFT earphone...');
    if fname == 0 % return if user hits CANCEL button 
        str = 'loading cancelled...';
        set(handles.textMessage, 'String', str);
        return;
    end
    % display message
    str = ['Loading LEFT earphone calibration data from ' fname];
    set(handles.textMessage, 'String', str);
    % attempt to load calibration file
    try 
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
        str = ['Error loading calibration file ' fname]; 
        set(handles.textMessage, 'String', str);
        errordlg(str, 'LoadCalL error'); 
    end
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function buttonLoadCALR_Callback(hObject, eventdata, handles)
    % display message
    str = '** calibration settings: Load CAL R clicked';
    set(handles.textMessage, 'String', str);
    % get file name 
    [fname, fpath] = ...
        uigetfile('*_cal2.mat', 'Load Cal data for RIGHT earphone...');
    if fname == 0 % return if user hits CANCEL button 
        str = 'loading cancelled...';
        set(handles.textMessage, 'String', str);
        return;
    end
    % display message
    str = ['Loading RIGHT earphone calibration data from ' fname];
    set(handles.textMessage, 'String', str);
    % attempt to load calibration file
    try 
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
        str = ['Error loading calibration file ' fname]; 
        set(handles.textMessage, 'String', str);
        errordlg(str, 'LoadCalR error'); 
    end
    % save handles structure
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function buttonPlotCAL_Callback(hObject, eventdata, handles)
    % display message
    str = '** calibration settings: Plot CAL clicked';
    set(handles.textMessage, 'String', str);
    % if neither L nor R is loaded then show error message and return 
    if ~handles.h2.calinfo.loadedR && ~handles.h2.calinfo.loadedL  
        str = 'no cal files loaded';
        set(handles.textMessage, 'String', str);
        return;
    end
    % call plotcal function
    TytoLogy2_plotcal(handles.h2.calinfo.loadedL, handles.h2.caldataL, ...
                      handles.h2.calinfo.loadedR, handles.h2.caldataR);
%--------------------------------------------------------------------------
function buttonDeleteCal_Callback(hObject, eventdata, handles)
    % display message
    str = '** calibration settings: Delete CAL clicked';
    set(handles.textMessage, 'String', str);
    % reset filenames and flags
    handles.h2.calinfo = FOCHS_init('CALINFO'); 
    handles.h2.caldataL = [];
    handles.h2.caldataR = [];
    update_ui_str(handles.textCALfileL, 'unloaded');
    update_ui_str(handles.textCALfileR, 'unloaded');
    % set both channels OFF
    handles.h2.search.LeftON = 0;
    handles.h2.search.RightON = 0;
    % reset to default
    handles.h2.search.limits.Freq = handles.h2.search.limits.defaultFreq;
    % uodate UI
    FOCHS_updateUI(handles, 'SEARCH:ATTEN');
    % disabling Plot CAL button and LEFT ON and Right ON checkboxes
    disable_ui(handles.buttonPlotCAL);
    disable_ui(handles.checkLeftON);
    disable_ui(handles.checkRightON);
    % save handles structure 
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Animal/Experiment settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editDate_Callback(hObject, eventdata, handles)
    % display message
    str = 'Date field is not editable';
    set(handles.textMessage, 'String', str);
    % reset to old value
    update_ui_str(hObject, handles.h2.animal.Date);
%--------------------------------------------------------------------------
function editAnimal_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: animal# changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.Animal = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editUnit_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: unit# changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.Unit = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editRec_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: rec# changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.Rec = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editPen_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: penetration# changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.Pen = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editAP_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: AP changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.AP = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editML_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: ML changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.ML = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editDepth_Callback(hObject, eventdata, handles)
    % display message
    str = '** experiment data settings: depth changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.animal.Depth = read_ui_str(hObject);
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editISI_Callback(hObject, eventdata, handles)
    % display message
    str = '** stimulus settings: ISI changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.stimulus.limits.ISI) 
        handles.h2.stimulus.ISI = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.stimulus.ISI);
    end
%--------------------------------------------------------------------------
function editDuration_Callback(hObject, eventdata, handles)
    % display message
    str = '** stimulus settings: duration changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.stimulus.limits.Duration) 
        handles.h2.stimulus.Duration = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.stimulus.Duration);
    end
%--------------------------------------------------------------------------
function editDelay_Callback(hObject, eventdata, handles)
    % display message
    str = '** stimulus settings: delay changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.stimulus.limits.Delay) 
        handles.h2.stimulus.Delay = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.stimulus.Delay);
    end
%--------------------------------------------------------------------------
function editRamp_Callback(hObject, eventdata, handles)
    % display message
    str = '** stimulus settings: ramp changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.stimulus.limits.Ramp) 
        handles.h2.stimulus.Ramp = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.stimulus.Ramp);
    end
%--------------------------------------------------------------------------
function checkRadVary_Callback(hObject, eventdata, handles)
    % update val
    handles.h2.stimulus.RadVary = read_ui_val(hObject); 
    guidata(hObject, handles); 
    % display message
    if handles.h2.stimulus.RadVary
        str = 'Initial phase will be varied';
    else
        str = 'Initial phase will be fixed';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkFrozenStim_Callback(hObject, eventdata, handles)
    % update val
    handles.h2.stimulus.Frozen = read_ui_val(hObject); 
    guidata(hObject, handles); 
    % display message
    if handles.h2.stimulus.Frozen
        str = 'Stimulus waveform will be frozen';
    else
        str = 'Stimulus waveform will be varied';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editAcqDuration_Callback(hObject, eventdata, handles)
    % display message
    str = '** TDT settings: AcqDuration changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.tdt.limits.AcqDuration)    
        handles.h2.tdt.AcqDuration = tmp;
        handles.h2.tdt.SweepPeriod = tmp + 10;
        update_ui_str(handles.editSweepPeriod, handles.h2.tdt.SweepPeriod);
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.tdt.AcqDuration);
    end
%--------------------------------------------------------------------------
function editSweepPeriod_Callback(hObject, eventdata, handles)
    % Note: SweepPeriod is determined as AcqDuration+10.
    % display message
    str = 'SweepPeriod is not editable. Change AcqDuration instead.';
    set(handles.textMessage, 'String', str);
    % reset to old value
    update_ui_str(hObject, handles.h2.tdt.SweepPeriod);
%--------------------------------------------------------------------------
function editTTLPulseDur_Callback(hObject, eventdata, handles)
    % display message
    str = '** TDT settings: TTL pulse dur changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.tdt.limits.TTLPulseDur) 
        handles.h2.tdt.TTLPulseDur = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.tdt.TTLPulseDur);
    end
%--------------------------------------------------------------------------
function editCircuitGain_Callback(hObject, eventdata, handles)
    % display message
    str = '** TDT settings: circuit gain changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.tdt.limits.CircuitGain) 
        handles.h2.tdt.CircuitGain = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.tdt.CircuitGain);
    end
%--------------------------------------------------------------------------
function editHPFreq_Callback(hObject, eventdata, handles)
    % display message 
    str = '** TDT settings: HP freq changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.tdt.limits.HPFreq) 
        handles.h2.tdt.HPFreq = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.tdt.HPFreq);
    end
%--------------------------------------------------------------------------
function editLPFreq_Callback(hObject, eventdata, handles)
    % display message
    str = '** TDT settings: LP freq changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.tdt.limits.LPFreq) 
        handles.h2.tdt.LPFreq = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.tdt.LPFreq);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I/O channel settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editOutputL_Callback(hObject, eventdata, handles)
    % display message
    str = '** I/O channel settings: output channel L changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.channels.OutputChannelL = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editOutputR_Callback(hObject, eventdata, handles)
    % display message
    str = '** I/O channel settings: output channel R changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.channels.OutputChannelR = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editInput1_Callback(hObject, eventdata, handles)
    % display message
    str = '** I/O channel settings: input channel 1 changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.channels.InputChannel1 = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editInput2_Callback(hObject, eventdata, handles)
    % display message
    str = '** I/O channel settings: input channel 2 changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.channels.InputChannel2 = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editInput3_Callback(hObject, eventdata, handles)
    % display message
    str = '** I/O channel settings: input channel 3 changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.channels.InputChannel3 = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
function editInput4_Callback(hObject, eventdata, handles)
    % display message
    str = '** I/O channel settings: input channel 4 changed';
    set(handles.textMessage, 'String', str);
    % update val
    handles.h2.channels.InputChannel4 = read_ui_str(hObject, 'n');
    guidata(hObject, handles);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spike Analysis settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editStartTime_Callback(hObject, eventdata, handles)
    % display message
    str = '** spike analysis settings: start time changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.analysis.limits.StartTime) 
        handles.h2.analysis.StartTime = tmp;
        guidata(hObject, handles);
    else % resetting to old value
        update_ui_str(hObject, handles.h2.analysis.StartTime);
    end
%--------------------------------------------------------------------------
function editEndTime_Callback(hObject, eventdata, handles)
    % display message
    str = '** spike analysis settings: end time changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.analysis.limits.EndTime) 
        handles.h2.analysis.EndTime = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.analysis.EndTime);
    end
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkboxes, editboxes and radio buttons for Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editCurveReps_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: #Reps changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = round(read_ui_str(hObject, 'n')); % round to integer
    if checkCurveLimits(tmp, handles.h2.stimulus.limits.Reps) 
        handles.h2.paramCurrent.Reps = tmp;
        FOCHS_storecurveparams; % save current parameters 
        guidata(hObject, handles);
    else % revert to old string
        str = sprintf('# Reps out of bounds [%d %d]', ... 
             handles.h2.stimulus.limits.Reps(1), handles.h2.stimulus.limits.Reps(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.Reps);
    end
%--------------------------------------------------------------------------
function editCurveITD_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: ITD changed';
    set(handles.textMessage, 'String', str);
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad ITD string'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.ITDstring); 
        return;
    end
    % check limits 
    if checkCurveLimits(tmparr, handles.h2.search.limits.ITD) 
        handles.h2.paramCurrent.ITDstring = tmpstr;
        handles.h2.paramCurrent.ITD = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        str = sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ITD(1), handles.h2.search.limits.ITD(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.ITDstring);
    end
%--------------------------------------------------------------------------
function editCurveILD_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: ILD changed';
    set(handles.textMessage, 'String', str);
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad ILD string'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.ILDstring); 
        return;
    end
    % check limits 
    if checkCurveLimits(tmparr, handles.h2.search.limits.ILD) 
        handles.h2.paramCurrent.ILDstring = tmpstr;
        handles.h2.paramCurrent.ILD = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string 
        str = sprintf('ILD range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ILD(1), handles.h2.search.limits.ILD(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.ILDstring);
    end
%--------------------------------------------------------------------------
function editCurveABI_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: ABI changed';
    set(handles.textMessage, 'String', str);
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad ABI string';
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.ABIstring); 
        return;
    end
    % check limits 
    if checkCurveLimits(tmparr, handles.h2.search.limits.ABI) 
        handles.h2.paramCurrent.ABIstring = tmpstr;
        handles.h2.paramCurrent.ABI = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        str = sprintf('ABI range out of bounds [%d %d]', ... 
             handles.h2.search.limits.ABI(1), handles.h2.search.limits.ABI(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.ABIstring);
    end
%--------------------------------------------------------------------------
function editCurveFreq_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: Freq changed';
    set(handles.textMessage, 'String', str);
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad Freq string'; 
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.Freqstring); 
        return;
    end
    % check limits
    if checkCurveLimits(tmparr, handles.h2.search.limits.Freq) 
        handles.h2.paramCurrent.Freqstring = tmpstr;
        handles.h2.paramCurrent.Freq = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % revert to old string
        str = sprintf('Freq range out of bounds [%d %d]', ... 
             handles.h2.search.limits.Freq(1), handles.h2.search.limits.Freq(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.Freqstring);
    end
%--------------------------------------------------------------------------
function editCurveBC_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: BC changed';
    set(handles.textMessage, 'String', str); 
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad BC string';
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.BCstring); % revert to old string 
        return;
    end
    % check limits
    if checkCurveLimits(tmparr, handles.h2.search.limits.BC) 
        handles.h2.paramCurrent.BCstring = tmpstr;
        handles.h2.paramCurrent.BC = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % if out of limits, then show error message and revert to old string
        str = sprintf('BC range out of bounds [%d %d]', ... 
             handles.h2.search.limits.BC(1), handles.h2.search.limits.BC(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.BCstring);
    end
%--------------------------------------------------------------------------
function editCurvesAMp_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: sAM percent changed';
    set(handles.textMessage, 'String', str);
    % check string  
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad sAM percent string';
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.sAMpstring); 
        return;
    end
    % check limits 
    if checkCurveLimits(tmparr, handles.h2.search.limits.sAMp) 
        handles.h2.paramCurrent.sAMpstring = tmpstr;
        handles.h2.paramCurrent.sAMp = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % if out of limits, then show error message and revert to old string
        str = sprintf('sAM percent range out of bounds [%d %d]', ... 
             handles.h2.search.limits.sAMp(1), handles.h2.search.limits.sAMp(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.sAMpstring);
    end
%--------------------------------------------------------------------------
function editCurvesAMf_Callback(hObject, eventdata, handles)
    % display message
    str = '** curves module: sAM freq changed';
    set(handles.textMessage, 'String', str);
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad sAM freq string';  
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.sAMfstring); 
        return;
    end
    % check limits 
    if checkCurveLimits(tmparr, handles.h2.search.limits.sAMf) 
        handles.h2.paramCurrent.sAMfstring = tmpstr;
        handles.h2.paramCurrent.sAMf = tmparr;
        FOCHS_storecurveparams; % save current parameters
        guidata(hObject, handles);
    else % if out of limits, then show error message and revert to old string
        str = sprintf('sAM freq range out of bounds [%d %d]', ... 
             handles.h2.search.limits.sAMf(1), handles.h2.search.limits.sAMf(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.paramCurrent.sAMfstring);
    end
%--------------------------------------------------------------------------
function checkCurveSpont_Callback(hObject, eventdata, handles)
    % update val
    handles.h2.curve.Spont = read_ui_val(hObject); 
    guidata(hObject, handles); 
    % display message
    if handles.h2.curve.Spont
        str = 'Spont trials will be used';
    else
        str = 'Spont trials will not be used';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkCurveTemp_Callback(hObject, eventdata, handles)
    % update val
    handles.h2.curve.Temp = read_ui_val(hObject); 
    guidata(hObject, handles); 
    % display message
    if handles.h2.curve.Temp
        str = 'Data will be saved to temp.dat file';
    else
        str = 'Temp file will not be used';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkCurveSaveStim_Callback(hObject, eventdata, handles)
    % update val
    handles.h2.curve.SaveStim = read_ui_val(hObject); 
    guidata(hObject, handles); 
    % display message
    if handles.h2.curve.SaveStim
        str = 'Stimulus waveform will be saved';
    else
        str = 'Stimulus waveform will not be saved';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function radioCurveType_SelectionChangeFcn(hObject, eventdata, handles)
    % get selected val 
    hSelected = hObject; 
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveTypeBF'
            handles.h2.paramCurrent = handles.h2.paramBF;
            str = '** curves module: BF curve selected';
        case 'radioCurveTypeITD'
            handles.h2.paramCurrent = handles.h2.paramITD;
            str = '** curves module: ITD curve selected';
        case 'radioCurveTypeILD'
            handles.h2.paramCurrent = handles.h2.paramILD;
            str = '** curves module: ILD curve selected';
        case 'radioCurveTypeABI'
            handles.h2.paramCurrent = handles.h2.paramABI;
            str = '** curves module: ABI curve selected';
        case 'radioCurveTypeBC'
            handles.h2.paramCurrent = handles.h2.paramBC;
            str = '** curves module: BC curve selected';
        case 'radioCurveTypesAMp'
            handles.h2.paramCurrent = handles.h2.paramsAMp;
            str = '** curves module: sAM percent curve selected';
        case 'radioCurveTypesAMf'
            handles.h2.paramCurrent = handles.h2.paramsAMf;
            str = '** curves module: sAM freq curve selected';
        case 'radioCurveTypeCF'
            handles.h2.paramCurrent = handles.h2.paramCF;
            str = '** curves module: CF curve selected';
        case 'radioCurveTypeCD'
            handles.h2.paramCurrent = handles.h2.paramCD;
            str = '** curves module: CD curve selected';
        case 'radioCurveTypePH'
            handles.h2.paramCurrent = handles.h2.paramPH;
            str = '** curves module: Phase Histogram selected';
    end
    % update UI
    FOCHS_updateUI(handles, 'CURVE');
    % save handles structure
    guidata(hObject, handles);
    % display message
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function radioCurveStim_SelectionChangeFcn(hObject, eventdata, handles)
    % get selected val 
    hSelected = hObject; 
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveStimNoise'
            handles.h2.curve.stimtype = 'NOISE'; 
            str = '** curves module: noise selected';
        case 'radioCurveStimTone'
            handles.h2.curve.stimtype = 'TONE'; 
            str = '** curves module: tone selected';
    end
    % save handles structure
    guidata(hObject, handles);
    % display message
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function radioCurveSide_SelectionChangeFcn(hObject, eventdata, handles)
    % get selected val 
    hSelected = hObject; 
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioCurveSideBoth'
            handles.h2.curve.side = 'BOTH'; 
            str = '** curves module: binaural selected';
        case 'radioCurveSideLeft'
            handles.h2.curve.side = 'LEFT'; 
            str = '** curves module: left selected';
        case 'radioCurveSideRight'
            handles.h2.curve.side = 'RIGHT'; 
            str = '** curves module: right selected'; 
    end
    % save handles structure
    guidata(hObject, handles);
    % display message
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkboxes, editboxes and radio buttons for Clicks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editClickSamples_Callback(hObject, eventdata, handles)
    % display message
    str = '** clicks module: #Samples changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Samples) 
        tmp = ceil(tmp/2)*2; %% round to even number 
        update_ui_str(hObject, tmp); %% update edit box 
        handles.h2.click.Samples = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Samples);
    end
%--------------------------------------------------------------------------
function editClickReps_Callback(hObject, eventdata, handles)
    % display message
    str = '** clicks module: #Reps changed';
    set(handles.textMessage, 'String', str);
    % check limits 
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Reps) 
        handles.h2.click.Reps = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Reps);
    end
%--------------------------------------------------------------------------
function editClickITD_Callback(hObject, eventdata, handles)
    % display message
    str = '** clicks module: ITD changed';
    set(handles.textMessage, 'String', str);
    % check string 
    tmpstr = read_ui_str(hObject);
    if isempty(strtrim(tmpstr)) % if empty string, then use non-numeric
        tmparr = false;
    else % for regular non-empty string
        tmparr = eval(tmpstr);  % evaluate the string to generate an array
        if isempty(tmparr) % if empty array, then use non-numeric
            tmparr = false;
        end
    end 
    % if string is not numeric, then show error and revert to old string 
    if ~isnumeric(tmparr(1)) 
        str = 'Bad Click ITD string';  
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.click.ITDstring); 
        return;
    end
    % check limits
    if checkCurveLimits(tmparr, handles.h2.click.limits.ITD) 
        handles.h2.click.ITDstring = tmpstr;
        handles.h2.click.ITD = tmparr;
        guidata(hObject, handles);
    else % if out of limits, then show error message and revert to old string
        str = sprintf('ITD range out of bounds [%d %d]', ... 
             handles.h2.click.limits.ITD(1), handles.h2.click.limits.ITD(2));
        set(handles.textMessage, 'String', str);
        update_ui_str(hObject, handles.h2.click.ITDstring);
    end
%--------------------------------------------------------------------------
function editClickLatten_Callback(hObject, eventdata, handles)
    % display message
    str = '** clicks module: Latten changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Latten) 
        handles.h2.click.Latten = tmp; 
        guidata(hObject, handles); 
    else % reset to old value 
        update_ui_str(hObject, handles.h2.click.Latten);
    end
%--------------------------------------------------------------------------
function editClickRatten_Callback(hObject, eventdata, handles)
    % display message
    str = '** clicks module: Ratten changed';
    set(handles.textMessage, 'String', str);
    % check limits
    tmp = read_ui_str(hObject, 'n');
    if checklim(tmp, handles.h2.click.limits.Ratten) 
        handles.h2.click.Ratten = tmp;
        guidata(hObject, handles);
    else % reset to old value
        update_ui_str(hObject, handles.h2.click.Ratten);
    end
%--------------------------------------------------------------------------
function radioClickType_SelectionChangeFcn(hObject, eventdata, handles)
    % get selected val 
    hSelected = hObject; % for R2007a
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioClickTypeCond'
            handles.h2.click.clicktype = 'COND'; 
            str = '** clicks module: condensed click selected';
        case 'radioClickTypeRare'
            handles.h2.click.clicktype = 'RARE'; 
            str = '** clicks module: rare click selected';
    end
    % save handles structure
    guidata(hObject, handles);
    % display message
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function radioClickSide_SelectionChangeFcn(hObject, eventdata, handles) %#ok<*DEFNU>
    % get selected val 
    hSelected = hObject; 
    tag = get(hSelected, 'Tag');
    switch tag
        case 'radioClickSideBoth'
            handles.h2.click.side = 'BOTH'; 
            str = '** clicks module: binaural click selected';
        case 'radioClickSideLeft'
            handles.h2.click.side = 'LEFT'; 
            str = '** clicks module: left click selected';
        case 'radioClickSideRight'
            handles.h2.click.side = 'RIGHT'; 
            str = '** clicks module: right click selected';
    end
    % save handles structure
    guidata(hObject, handles);
    % display message
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot settings callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function buttonClearPlot_Callback(hObject, eventdata, handles) %#ok<*INUSL>
    % display message 
    str = '** clear plot';
    set(handles.textMessage, 'String', str);
    % clear figs
    cla(handles.axesResp);
    cla(handles.axesUpclose);
%--------------------------------------------------------------------------
% function radioPlot_SelectionChangeFcn(hObject, eventdata, handles)
%     if(handles.DEBUG) % debug mode
%         str = '** plot setting changed';
%         disp(str); set(handles.textMessage, 'String', str);
%     end
%     hSelected = hObject; % for R2007a
%   % hSelected = get(hObject,'SelectedObject'); % for later matlab versions?
%     tag = get(hSelected, 'Tag');
%     switch tag
%         case 'radioShowAll'
%             disp('Plot ALL')
%             handles.h2.plots = HPSearch2_init('PLOTS:ALL');
%         case 'radioShowResp'
%             disp('Plot Response Only')
%             handles.h2.plots = HPSearch2_init('PLOTS:RESP');
%         case 'radioShowRU'
%             disp('Plot Response + Upclose')
%             handles.h2.plots = HPSearch2_init('PLOTS:REUP');
%         case 'radioShowNone'
%             disp('Plot OFF')
%             handles.h2.plots = HPSearch2_init('PLOTS:NONE');
%         end
%     guidata(hObject, handles);
%--------------------------------------------------------------------------
function checkShowCh1_Callback(hObject, eventdata, handles)
    % read the check box
    handles.h2.plots.Ch1 = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.plots.Ch1
        str = '** Channel 1 will be plotted';
    else
        str = '** Channel 1 will not be plotted';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkShowCh2_Callback(hObject, eventdata, handles)
    % read the check box
    handles.h2.plots.Ch2 = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.plots.Ch2
        str = '** Channel 2 will be plotted';
    else
        str = '** Channel 2 will not be plotted';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkShowCh3_Callback(hObject, eventdata, handles)
    % read the check box
    handles.h2.plots.Ch3 = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.plots.Ch3
        str = '** Channel 3 will be plotted';
    else
        str = '** Channel 3 will not be plotted';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkShowCh4_Callback(hObject, eventdata, handles)
    % read the check box
    handles.h2.plots.Ch4 = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.plots.Ch4
        str = '** Channel 4 will be plotted';
    else
        str = '** Channel 4 will not be plotted';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkPlotResp_Callback(hObject, eventdata, handles)
    % read the check box
    handles.h2.plots.plotResp = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.plots.plotResp
        str = '** Responses will be plotted';
    else
        str = '** Responses will not be plotted';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
function checkPlotUpclose_Callback(hObject, eventdata, handles)
    % read the check box
    handles.h2.plots.plotUpclose = read_ui_val(hObject);
    guidata(hObject, handles); 
    % display message
    if handles.h2.plots.plotUpclose
        str = '** Upclosed traces will be plotted';
    else
        str = '** Upclosed traces will not be plotted';
    end
    set(handles.textMessage, 'String', str);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% editboxes for analyzed data --- editing these boxes has no effects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function editAmpCh1_Callback(hObject, eventdata, handles) %#ok<*INUSD>
%--------------------------------------------------------------------------
function editAmpCh2_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editAmpCh3_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editAmpCh4_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editFreqCh1_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editFreqCh2_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editFreqCh3_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editFreqCh4_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editPhiCh1_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editPhiCh2_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editPhiCh3_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editPhiCh4_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editSTDCh1_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editSTDCh2_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editSTDCh3_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function editSTDCh4_Callback(hObject, eventdata, handles)
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
function editOutputL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editOutputR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editInput1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editInput2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editInput3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editInput4_CreateFcn(hObject, eventdata, handles)
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
function editStartTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editEndTime_CreateFcn(hObject, eventdata, handles)
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
function editAmpCh1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAmpCh2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAmpCh3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editAmpCh4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFreqCh1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFreqCh2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFreqCh3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFreqCh4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editPhiCh1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editPhiCh2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editPhiCh3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editPhiCh4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSTDCh1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSTDCh2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSTDCh3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSTDCh4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
