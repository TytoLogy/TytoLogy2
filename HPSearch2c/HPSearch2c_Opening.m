% HPSearch2c_Opening.m
%------------------------------------------------------------------------
% 
% Script that runs just before HPSearch2c is made visible. 
% This script is called from HPSearch2c_OpeningFcn of HPSearch2c.
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_Opening): 2011-2012 by GA
% Adopted for HPSearch2a (HPSearch2a_Opening): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_Opening): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_Opening): Jan 2015 by GA 
%  - added code for external stimulus 
%------------------------------------------------------------------------

handles.h2 = struct();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT I/O settings 
%  -- assuming that 'No_TDT' is selected at the time of initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.WithoutTDT = 1;       % default is 'No_TDT'
handles.TDThardware = 'NO_TDT'; 
handles.h2.config = HPSearch2c_config(handles.TDThardware);
handles.indev = [];
handles.outdev = [];
handles.zBUS = [];
handles.PA5L = [];
handles.PA5R = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data path settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.DATAPATH = pwd;
idx_filesep = find( handles.DATAPATH == filesep, 1, 'last' );
handles.SETTINGSPATH = [ handles.DATAPATH( 1:idx_filesep ), ...
                         'TytoSettings', filesep, username2 ];
if ~exist( handles.SETTINGSPATH, 'dir')
    mkdir( handles.SETTINGSPATH );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT lock file settings 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.TDTLOCKFILE = [handles.SETTINGSPATH, filesep, '.tdtlock.mat'];
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
handles.h2.calinfo = HPSearch2c_init('CALINFO');
handles.h2.caldataL = [];
handles.h2.caldataR = [];
% -- animal info
handles.h2.animal = HPSearch2c_init('ANIMAL');
% -- search parameters
handles.h2.search = HPSearch2c_init('SEARCH:PARAMS');
handles.h2.search.limits = HPSearch2c_init('SEARCH:LIMITS');
% -- stimulus parameters
handles.h2.stimulus = HPSearch2c_init('STIMULUS:PARAMS'); 
handles.h2.stimulus.limits = HPSearch2c_init('STIMULUS:LIMITS');
% -- TDT parameters
handles.h2.tdt = HPSearch2c_init('TDT:PARAMS');
handles.h2.tdt.limits = HPSearch2c_init('TDT:LIMITS');
% -- TDT I/O channels
handles.h2.channels = HPSearch2c_init(['CHANNELS:' handles.TDThardware]); % default: 'NO_TDT'
% -- spike analysis settings
handles.h2.analysis = HPSearch2c_init('ANALYSIS:PARAMS');
handles.h2.analysis.limits = HPSearch2c_init('ANALYSIS:LIMITS');
% -- plots settings
handles.h2.plots = HPSearch2c_init('PLOTS');
% -- parameters for curve recordings
handles.h2.curve = HPSearch2c_init('CURVE:TYPE');
% -- parameters for various curve settings
handles.h2.paramBF = HPSearch2c_init('CURVE:BF');
handles.h2.paramITD = HPSearch2c_init('CURVE:ITD');
handles.h2.paramILD = HPSearch2c_init('CURVE:ILD');
handles.h2.paramABI = HPSearch2c_init('CURVE:ABI');
handles.h2.paramBC = HPSearch2c_init('CURVE:BC');
handles.h2.paramFILDL = HPSearch2c_init('CURVE:FILDL');
handles.h2.paramFILDR = HPSearch2c_init('CURVE:FILDR');
handles.h2.paramBeat = HPSearch2c_init('CURVE:BEAT');
handles.h2.paramsAMp = HPSearch2c_init('CURVE:SAMP');
handles.h2.paramsAMf = HPSearch2c_init('CURVE:SAMF');
handles.h2.paramCF = HPSearch2c_init('CURVE:CF');
handles.h2.paramCD = HPSearch2c_init('CURVE:CD');
handles.h2.paramPH = HPSearch2c_init('CURVE:PH');
handles.h2.paramCurrent = handles.h2.paramBF;
% -- parameters for click recordings
handles.h2.click = HPSearch2c_init('CLICK:PARAMS');
handles.h2.click.limits = HPSearch2c_init('CLICK:LIMITS');
% -- parameters for external stimulus --- added Jan 2015 by GA
handles.h2.extstim = HPSearch2c_init('EXTSTIM:PARAMS');
handles.h2.extstim.limits = HPSearch2c_init('EXTSTIM:LIMITS');
handles.h2.extstim.fileinfo = HPSearch2c_init('EXTSTIM:FILEINFO');
handles.h2.extstim.outsig = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create external plotting window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles = HPPlotWindow( handles );
% get matlab version
tmp = version( '-release' );
handles.version = str2double( tmp( 1:end-1 ));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saving parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guidata(hObject, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update GUI 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HPSearch2c_updateUI(handles,'ANIMAL');
HPSearch2c_updateUI(handles,'SEARCH');
HPSearch2c_updateUI(handles,'STIMULUS');
HPSearch2c_updateUI(handles,'TDT');
HPSearch2c_updateUI(handles,'CHANNELS');
HPSearch2c_updateUI(handles,'ANALYSIS');
HPSearch2c_updateUI(handles,'PLOTS');
HPSearch2c_updateUI(handles,'CURVE');
HPSearch2c_updateUI(handles,'CLICK');
HPSearch2c_updateUI(handles,'EXTSTIM'); % --- added Jan 2015 by GA

