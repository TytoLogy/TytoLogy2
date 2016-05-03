%------------------------------------------------------------------------
% FOCHS_Opening.m
%------------------------------------------------------------------------
% 
% Script that runs just before the FOCHS GUI is made visible. 
% This script is called from FOCHS_OpeningFcn in FOCHS.m.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version (HPSearch): 2009-2011 by SJS
% Upgraded Version (HPSearch2): 2011-2012 by GA
% Four-channel Input Version (FOCHS): 2012 by GA
% Optogen mods: 2016 by SJS
%------------------------------------------------------------------------

handles.h2 = struct();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT I/O settings 
%  -- assuming that 'No_TDT' is selected at the time of initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%handles.WithoutTDT = 1; 
handles.TDThardware = 'NO_TDT'; % default is 'No_TDT'
handles.h2.config = FOCHS_config(handles.TDThardware);
handles.indev = [];
handles.outdev = [];
handles.zBUS = [];
handles.PA5L = [];
handles.PA5R = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data path settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.DATAPATH = pwd;
handles.SETTINGSPATH = ['C:\TytoLogy2\TytoSettings\' username];
if ~exist(handles.SETTINGSPATH, 'dir')
    mkdir('C:\TytoLogy2\TytoSettings\', username);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT lock file settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.TDTLOCKFILE = [handles.SETTINGSPATH '\.tdtlock.mat'];
handles.h2.config.TDTLOCKFILE = handles.TDTLOCKFILE;
%-------------------------------------
% check if the tdt lock has been set 
% if so, this might indicate that a program that uses the TDT hardware 
% is running or has crashed without cleaning up (SJS)
%-------------------------------------
if exist(handles.h2.config.TDTLOCKFILE, 'file')
    % check if TDTINIT flag is set
    load(handles.h2.config.TDTLOCKFILE);
    if TDTINIT % if TDTINIT is set, ask if user wants to override
        usr_ans = query_user('ignore TDT lock');
        if usr_ans 
            TDTINIT = 0;
            save(handles.TDTLOCKFILE, 'TDTINIT');
        else
            % otherwise, close the program
            CloseRequestFcn(hObject, [], handles)
        end
    end
else % if TDT lock file does not exist 
    % display message 
    str = [mfilename ': Creating TDT Lock file: ' handles.TDTLOCKFILE];
    set(handles.textMessage, 'String', str);
    disp(str);
    % create TDT lock file 
    TDTINIT = 0;
    save(handles.h2.config.TDTLOCKFILE, 'TDTINIT');
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- parameters for calibration files
handles.h2.calinfo = FOCHS_init('CALINFO');
handles.h2.caldataL = [];
handles.h2.caldataR = [];
% -- animal info
handles.h2.animal = FOCHS_init('ANIMAL');
% -- search parameters
handles.h2.search = FOCHS_init('SEARCH:PARAMS');
handles.h2.search.limits = FOCHS_init('SEARCH:LIMITS');
% -- stimulus parameters
handles.h2.stimulus = FOCHS_init('STIMULUS:PARAMS'); 
handles.h2.stimulus.limits = FOCHS_init('STIMULUS:LIMITS');
% -- TDT parameters
handles.h2.tdt = FOCHS_init('TDT:PARAMS');
handles.h2.tdt.limits = FOCHS_init('TDT:LIMITS');
% -- TDT I/O channels ---- default TDT hardware = 'NO_TDT'
handles.h2.channels = FOCHS_init(['CHANNELS:' handles.TDThardware]); 
% -- spike analysis settings
handles.h2.analysis = FOCHS_init('ANALYSIS:PARAMS');
handles.h2.analysis.limits = FOCHS_init('ANALYSIS:LIMITS');
% -- plots settings
handles.h2.plots = FOCHS_init('PLOTS:DEFAULT');
% -- parameters for curve recordings
handles.h2.curve = FOCHS_init('CURVE:TYPE');
% -- parameters for various curve settings
handles.h2.paramBF = FOCHS_init('CURVE:BF');
handles.h2.paramITD = FOCHS_init('CURVE:ITD');
handles.h2.paramILD = FOCHS_init('CURVE:ILD');
handles.h2.paramABI = FOCHS_init('CURVE:ABI');
handles.h2.paramBC = FOCHS_init('CURVE:BC');
handles.h2.paramsAMp = FOCHS_init('CURVE:SAMP');
handles.h2.paramsAMf = FOCHS_init('CURVE:SAMF');
handles.h2.paramCF = FOCHS_init('CURVE:CF');
handles.h2.paramCD = FOCHS_init('CURVE:CD');
handles.h2.paramPH = FOCHS_init('CURVE:PH');
handles.h2.paramCurrent = handles.h2.paramBF;
% -- parameters for click recordings
handles.h2.click = FOCHS_init('CLICK:PARAMS');
handles.h2.click.limits = FOCHS_init('CLICK:LIMITS');
% -- parameters for optical stimulus
handles.h2.optical = FOCHS_init('OPTICAL');
handles.h2.optical.limits = FOCHS_init('OPTICAL:LIMITS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saving parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guidata(hObject, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update GUI 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FOCHS_updateUI(handles,'ANIMAL');
FOCHS_updateUI(handles,'SEARCH');
FOCHS_updateUI(handles,'STIMULUS');
FOCHS_updateUI(handles,'TDT');
FOCHS_updateUI(handles,'CHANNELS');
FOCHS_updateUI(handles,'ANALYSIS');
FOCHS_updateUI(handles,'PLOTS');
FOCHS_updateUI(handles,'CURVE');
FOCHS_updateUI(handles,'CLICK');
FOCHS_updateUI(handles, 'OPTICAL');
