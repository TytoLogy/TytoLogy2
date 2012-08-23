% HPSearch2_Opening.m
%------------------------------------------------------------------------
% 
% Script that runs just before HPSearch2 is made visible. 
% This script is called from HPSearch2_OpeningFcn of HPSEarch2.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Originally Written (HPSearch): 2009-2011 by SJS
% Updated Version Written (HPSearch2_Opening): 2011-2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

handles.h2 = struct();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT I/O settings 
%  -- assuming that 'No_TDT' is selected at the time of initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.WithoutTDT = 1;       % default is 'No_TDT'
handles.TDThardware = 'NO_TDT'; 
handles.h2.config = HPSearch2_config(handles.TDThardware);
handles.indev = [];
handles.outdev = [];
handles.zBUS = [];
handles.PA5L = [];
handles.PA5R = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data path settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.DATAPATH = pwd;
handles.SETTINGSPATH = ['C:\TytoLogy2\TytoSettings\' username2];
if ~exist(handles.SETTINGSPATH, 'dir')
    mkdir('C:\TytoLogy2\TytoSettings\', username2);
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
if exist(handles.TDTLOCKFILE, 'file')
	load(handles.TDTLOCKFILE);
	if TDTINIT
		% if yes, see if user wants to override
		usr_ans = query_user('ignore TDT lock');
		if usr_ans
			TDTINIT = 0;
			save(handles.TDTLOCKFILE, 'TDTINIT');
		else
			% otherwise, close the program
			CloseRequestFcn(hObject, [], handles)
        end
    end
else
	disp([mfilename ': Creating TDT Lock file: ' handles.TDTLOCKFILE])
	TDTINIT = 0;
	save(handles.TDTLOCKFILE, 'TDTINIT');
end	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- parameters for calibration files
handles.h2.calinfo = HPSearch2_init('CALINFO');
handles.h2.caldataL = [];
handles.h2.caldataR = [];
% -- animal info
handles.h2.animal = HPSearch2_init('ANIMAL');
% -- search parameters
handles.h2.search = HPSearch2_init('SEARCH:PARAMS');
handles.h2.search.limits = HPSearch2_init('SEARCH:LIMITS');
% -- stimulus parameters
handles.h2.stimulus = HPSearch2_init('STIMULUS:PARAMS'); 
handles.h2.stimulus.limits = HPSearch2_init('STIMULUS:LIMITS');
% -- TDT parameters
handles.h2.tdt = HPSearch2_init('TDT:PARAMS');
handles.h2.tdt.limits = HPSearch2_init('TDT:LIMITS');
% -- TDT I/O channels
handles.h2.channels = HPSearch2_init(['CHANNELS:' handles.TDThardware]); % default: 'NO_TDT'
% -- spike analysis settings
handles.h2.analysis = HPSearch2_init('ANALYSIS:PARAMS');
handles.h2.analysis.limits = HPSearch2_init('ANALYSIS:LIMITS');
% -- plots settings
handles.h2.plots = HPSearch2_init('PLOTS:RESP');
% -- parameters for curve recordings
handles.h2.curve = HPSearch2_init('CURVE:TYPE');
% -- parameters for various curve settings
handles.h2.paramBF = HPSearch2_init('CURVE:BF');
handles.h2.paramITD = HPSearch2_init('CURVE:ITD');
handles.h2.paramILD = HPSearch2_init('CURVE:ILD');
handles.h2.paramABI = HPSearch2_init('CURVE:ABI');
handles.h2.paramBC = HPSearch2_init('CURVE:BC');
handles.h2.paramsAMp = HPSearch2_init('CURVE:SAMP');
handles.h2.paramsAMf = HPSearch2_init('CURVE:SAMF');
handles.h2.paramCF = HPSearch2_init('CURVE:CF');
handles.h2.paramCD = HPSearch2_init('CURVE:CD');
handles.h2.paramPH = HPSearch2_init('CURVE:PH');
handles.h2.paramCurrent = handles.h2.paramBF;
% -- parameters for click recordings
handles.h2.click = HPSearch2_init('CLICK:PARAMS');
handles.h2.click.limits = HPSearch2_init('CLICK:LIMITS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saving parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guidata(hObject, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update GUI 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HPSearch2_updateUI(handles,'ANIMAL');
HPSearch2_updateUI(handles,'SEARCH');
HPSearch2_updateUI(handles,'STIMULUS');
HPSearch2_updateUI(handles,'TDT');
HPSearch2_updateUI(handles,'CHANNELS');
HPSearch2_updateUI(handles,'ANALYSIS');
HPSearch2_updateUI(handles,'PLOTS');
HPSearch2_updateUI(handles,'CURVE');
HPSearch2_updateUI(handles,'CLICK');

