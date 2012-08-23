function [ outhandles, outflag ] = HPSearch_TDTopen(config, varargin)
%------------------------------------------------------------------------
%[ outhandles, outflag ] = HPSearch2_TDTopen(config, varargin)
%------------------------------------------------------------------------
% 
%--- Initializes TDT I/O Hardware ----------------------------------------
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	config		matlab struct containing configuration information
%   varargin    for future use
% Output Arguments:
% 	outhandles  handle containing indev, outdev, zBUS, PA5L, PA5R
%   outflag    flag to show if TDT is successfully initialized 
%              -1: error 
%               0: not initialized 
%               1: success 
%               2: already initialized
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida 
%	sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch_TDTopen): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_TDTopen): 2011-2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

disp([mfilename ': ...starting TDT devices...']);
outflag = 0; % not initialized

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDTINIT_FORCE is usually 0, unless user chooses 'RESTART' 
% if TDTINIT is set in the .tdtlock.mat file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TDTINIT_FORCE = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if the TDT lock file (.tdtlock.mat) exists 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(config.TDTLOCKFILE, 'file')
	disp([mfilename ': TDT lock file not found: ', config.TDTLOCKFILE]);
	disp('Creating lock file, assuming TDT hardware is not initialized');
	TDTINIT = 0;
	save(config.TDTLOCKFILE, 'TDTINIT');
else
	load(config.TDTLOCKFILE); 	% load the lock information
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the lock variable (TDTINIT) in the TDT lock file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TDTINIT
	questStr = {'TDTINIT already set in .tdtlock.mat', ...
				'TDT Hardware might be active.', ...
				'Continue, Restart TDT Hardware, or Abort?'};
    titleStr = 'HPSearch2: TDTINIT error';
	respStr = questdlg(questStr, titleStr, 'Do_Nothing', 'Restart', 'Abort', 'Abort');
	
	switch upper(respStr)
		case 'DO_NOTHING'
			disp([mfilename ': continuing anyway...'])
            outhandles = [];
            outflag = 2;  % already initialized
            return;		
		case 'ABORT'
			disp([mfilename ': aborting initialization...'])
            outhandles = [];
			outflag = -1;  % error state
            return;
		case 'RESTART'
			disp([mfilename ': forcing to start TDT hardware...'])
			TDTINIT_FORCE = 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if TDTINIT is not set (TDT hardware not initialized) OR if
% TDTINIT_FORCE is set, initialize TDT hardware
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~TDTINIT || TDTINIT_FORCE
	disp([mfilename ': Configuration = ' config.CONFIGNAME]); 

    %------------------------------------------------------------------
    % initialize the outhandles structure
    %------------------------------------------------------------------
    outhandles = struct();
    outhandles.indev = config.indev; % Fs, Dnum, Circuit_Path, Circuit_Name
    outhandles.indev.C = [];
    outhandles.indev.handle = [];
    outhandles.indev.status = 0;
    outhandles.outdev = config.outdev;
    outhandles.outdev.C = [];
    outhandles.outdev.handle = [];
    outhandles.outdev.status = 0;

    %------------------------------------------------------------------
    % setting zBUS/indev/outdev/PA5 structure (containig function handles)
    % accoring to the config info. Note: setiodev() is defined at the end 
    %------------------------------------------------------------------
    [ zbus, idev, odev, pa5 ] = setiodev(config);
    
    %------------------------------------------------------------------
    % initialize zBUS, RX*, PA5; then load and start circuits
    % zBUS.initFunc, indev.initFunc, indev.loadFunc, indev.runFunc etc. are defined below
    %------------------------------------------------------------------
    try
        % Initialize zBus control
        disp('...starting zBUS...')
        tmpdev = zbus.initFunc('GB');
        outhandles.zBUS.C = tmpdev.C;
        outhandles.zBUS.handle = tmpdev.handle;
        outhandles.zBUS.status = tmpdev.status;
        % Initialize RX* for input
        disp(['...starting ' config.indev.hardware ' for spike input...'])
        tmpdev = idev.initFunc('GB', outhandles.indev.Dnum);
        outhandles.indev.C = tmpdev.C;
        outhandles.indev.handle = tmpdev.handle;
        outhandles.indev.status = tmpdev.status;
        % Initialize RX* for output
        disp(['...starting ' config.outdev.hardware ' for sound input...'])
        tmpdev = odev.initFunc('GB', outhandles.outdev.Dnum);
        outhandles.outdev.C = tmpdev.C;
        outhandles.outdev.handle = tmpdev.handle;
        outhandles.outdev.status = tmpdev.status;
        % Initialize Attenuators
        disp('...starting PA5...')
        outhandles.PA5L = pa5.initFunc('GB', 1);
        outhandles.PA5R = pa5.initFunc('GB', 2);
        % Load circuits
        disp('...loading circuits...')
        outhandles.indev.status  = idev.loadFunc(outhandles.indev);
        outhandles.outdev.status = odev.loadFunc(outhandles.outdev);
        if outhandles.outdev.status == -99  % indev=outdev
            outhandles.outdev.status = outhandles.indev.status; 
        end
        % Starts Circuits
        disp('...starting circuits...')
        idev.runFunc(outhandles.indev);
        odev.runFunc(outhandles.outdev);
        % Get the input and output sampling rates
        outhandles.indev.Fs  = idev.samplefreqFunc(outhandles.indev);
        outhandles.outdev.Fs = odev.samplefreqFunc(outhandles.outdev);
        if outhandles.outdev.Fs == -99  % indev=outdev
            outhandles.outdev.Fs = outhandles.indev.Fs; 
        end
        disp(['indev frequency (Hz) = '  num2str(outhandles.indev.Fs)]);
        disp(['outdev frequency (Hz) = ' num2str(outhandles.outdev.Fs)]);
        % Set the lock
        TDTINIT = 1; 
        outflag = 1; % success
    catch
        TDTINIT = 0;
        outflag = -1; % TDT initialization failed  
        disp([mfilename ': error starting TDT hardware'])
        disp(lasterror);
    end

    % save TDTINIT in lock file
    save(config.TDTLOCKFILE, 'TDTINIT');
    return;
end

%--------------------------------------------------------------------------
% internal functions
%--------------------------------------------------------------------------
function out = Dummyinit(varargin)
    out.C = [];
    out.handle = [];
    out.status = 0;
%--------------------------------------------------------------------------
function [ zbus, idev, odev, pa5 ] = setiodev(config)
    str = upper(config.CONFIGNAME);
    switch str
        case 'NO_TDT' % no TDT hardware is used
            zbus.initFunc = @Dummyinit;
            idev.initFunc = @Dummyinit;
            odev.initFunc = @Dummyinit;
            idev.loadFunc = @(varargin) -1;
            odev.loadFunc = @(varargin) -1;
            idev.runFunc  = @(varargin) -1;
            odev.runFunc  = @(varargin) -1;
            idev.samplefreqFunc = @(varargin) 50000;
            odev.samplefreqFunc = @(varargin) 50000;
            pa5.initFunc = @Dummyinit;
 
        case 'RX8_50K' % since indev=outdev, initFunc should be called only once
            zbus.initFunc = @Dummyinit;
            idev.initFunc = @RX8init;
            odev.initFunc = @Dummyinit; 
            idev.loadFunc = @RPload2;
            odev.loadFunc = @(varargin) -99; 
            idev.runFunc  = @RPrun;
            odev.runFunc  = @(varargin) -99; 
            idev.samplefreqFunc = @RPsamplefreq;
            odev.samplefreqFunc = @(varargin) -99;
            pa5.initFunc     = @PA5init;
 
        case 'RX6_50K' % since indev=outdev, initFunc should be called only once
            zbus.initFunc = @Dummyinit;
            idev.initFunc = @RX6init2;  % this is the only difference from RX8
            odev.initFunc = @Dummyinit; 
            idev.loadFunc = @RPload2;
            odev.loadFunc = @(varargin) -99; 
            idev.runFunc  = @RPrun;
            odev.runFunc  = @(varargin) -99;
            idev.samplefreqFunc = @RPsamplefreq;
            odev.samplefreqFunc = @(varargin) -99;
            pa5.initFunc     = @PA5init;
 
        case 'MEDUSA' % caution: not fully implemented yet (GA, Feb 2012)
            zbus.initFunc = @zBUSinit; 
            idev.initFunc = @RX5init; 
            odev.initFunc = @RX8init; 
            idev.loadFunc = @RPload;
            odev.loadFunc = @RPload;
            idev.runFunc  = @RPrun;
            odev.runFunc  = @RPrun;
            idev.samplefreqFunc = @RPsamplefreq;
            odev.samplefreqFunc = @RPsamplefreq;
            pa5.initFunc     = @PA5init;
 
        end
