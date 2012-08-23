function [ outhandles, outflag ] = HPSearch2_TDTclose(config, indev, outdev, zBUS, PA5L, PA5R)
%------------------------------------------------------------------------
%[ outhandles, outflag ] = HPSearch2_TDTclose(config, indev, outdev, zBUS, PA5L, PA5R)
%------------------------------------------------------------------------
% 
% Closes/shuts down TDT I/O Hardware for HPSearch program
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	config		matlab struct containing configuration information
%   indev       matlab struct containing input device information
%   outdev      matlab struct containing output device information
%   zBUS        matlab struct containing zBUS device information
%   PA5L        matlab struct containing PA5 (left) device information
%   PA5R        matlab struct containing PA5 (right) device information
% Output Arguments:
% 	outhandles  handle containing indev, outdev, zBUS, PA5L, PA5R
%   outflag    flag to show if TDT is successfully terminated 
%               -1: error
%                0: not terminated 
%                1: success
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag & Go Ashida
%	sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch_TDTclose): 2009-2011 by SJS
% Upgraded Version Written (HPSearch2_TDTclose): 2011-2012 by GA
%
% Revisions: modified version for HPSearch2
% 
%------------------------------------------------------------------------

disp([ mfilename ': ...closing TDT devices...']);
outflag = 0; % not terminated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the TDT lock file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(config.TDTLOCKFILE, 'file')
	disp([ mfilename ': TDT lock file not found: ', config.TDTLOCKFILE ]);
	disp('Creating lock file, assuming TDT hardware is not initialized');
	TDTINIT = 0;
	save(config.TDTLOCKFILE, 'TDTINIT');
else
	load(config.TDTLOCKFILE); 	% load the lock information
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exit gracefully (close TDT objects, etc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TDTINIT
    outhandles = struct();

    %------------------------------------------------------------------
    % setting zBUS/indev/outdev/PA5 structure accoring to the config info
    % setiodev() are defined below
    %------------------------------------------------------------------
    [ zbus, idev, odev, pa5 ] = setiodev(config);

    %------------------------------------------------------------------
    % terminate PA5, RX*, zBUS 
    % pa5.closeFunc, indev.closeFunc, zbus.closeFunc etc. are defined below
    %------------------------------------------------------------------
    disp('...closing PA5L')
    outhandles.PA5L.status = pa5.closeFunc(PA5L);
    disp('...closing PA5R')
    outhandles.PA5R.status = pa5.closeFunc(PA5R);
    disp('...closing indev')
    outhandles.indev.status = idev.closeFunc(indev);
    disp('...closing outdev')
    outhandles.outdev.status = odev.closeFunc(outdev);
    if outhandles.outdev.status == -99  % indev=outdev
        outhandles.outdev.status = outhandles.indev.status; 
    end
    disp('...closing zBUS')
    outhandles.zBUS.status = zbus.closeFunc(zBUS);
    % Reset TDTINIT
    TDTINIT = 0;
    save(config.TDTLOCKFILE, 'TDTINIT');
    outflag = 1;
else
	disp([mfilename ': TDTINIT is not set!'])
    outflag = -1;
    outhandles = [];
end

%--------------------------------------------------------------------------
% internal function
%--------------------------------------------------------------------------
function [ zbus, idev, odev, pa5 ] = setiodev(config)
    str = upper(config.indev.hardware);
    switch str
        case 'NONE' % no TDT hardware is used
            zbus.closeFunc = @(varargin) -1;  
            idev.closeFunc = @(varargin) -1; 
            odev.closeFunc = @(varargin) -1; 
            pa5.closeFunc  = @(varargin) -1; 

        case { 'RX6', 'RX8' } % since indev=outdev, closeFunc should be called only once
            zbus.closeFunc = @(varargin) 0;  % does nothing but returns the success flag
            idev.closeFunc = @RPclose; 
            odev.closeFunc = @(varargin) -99; 
            pa5.closeFunc  = @PA5close;

        case 'MEDUSA' % caution: not fully implemented yet (GA, Feb 2012)
            zbus.closeFunc = @zBUSclose; 
            idev.closeFunc = @RPclose; 
            odev.closeFunc = @RPclose; 
            pa5.closeFunc  = @PA5close;

        end
