function out = FOCHS_config(stype)
%------------------------------------------------------------------------
% out = FOCHS_config(stype)
%------------------------------------------------------------------------
% 
% Sets TDT configuration parameters.
%
%------------------------------------------------------------------------
% Input Arguments:
% 	stype		string
%
% Output Arguments:
% 	out         struct containing settings for requested type
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Original Version (HPSearch_init): 2009-2011 by SJS
% Upgraded Version (HPSearch2_config): 2011-2012 by GA
% Four-channel Input Version (FOCHS_config): 2012 by GA  
%------------------------------------------------------------------------

%----------------------------------------------------------------------
% check input argument
%----------------------------------------------------------------------
if ~nargin
	stype = '';
end
stype = upper(stype);

%----------------------------------------------------------------------
% return desired information
%----------------------------------------------------------------------
switch stype
    case 'NO_TDT'
        out.CONFIGNAME = stype;
        % function handles
        out.ioFunc = @FOCHS_NoTDT_spikeio;
        out.TDTsetFunc = @FOCHS_NoTDT_settings;
        out.setattenFunc = @(varargin) -1;
        % input device
        out.indev.hardware = 'NONE';
        out.indev.Fs = 0;
        out.indev.Circuit_Path = [];
        out.indev.Circuit_Name = [];
        out.indev.Dnum = 0; % device number
        % output device
        out.outdev.hardware = 'NONE';
        out.outdev.Fs = 0;
        out.outdev.Circuit_Path = [];
        out.outdev.Circuit_Name = [];
        out.outdev.Dnum = 0; % device number
        return;

    case 'RX8_50K' % use RX8 for both input and output
        out.CONFIGNAME = stype;
        % function handles
        out.ioFunc = @FOCHS_spikeio;
        out.TDTsetFunc = @FOCHS_RX8settings;
        out.setattenFunc = @PA5setatten;
        % input device
        out.indev.hardware = 'RX8';
        out.indev.Fs = 50000;
        out.indev.Circuit_Path = 'C:\TytoLogy2\toolbox2\TDTcircuits\';
        out.indev.Circuit_Name = 'RX8_50k_FourChannelInput';
        out.indev.Dnum = 1; % device number
        % output device
        out.outdev.hardware = 'RX8'; % same device used for both input and output
        out.outdev.Fs = 50000;
        out.outdev.Circuit_Path = ''; 
        out.outdev.Circuit_Name = '';
        out.outdev.Dnum = 1; % device number
        return;

    % if the argument is not known...
    otherwise
		disp([mfilename ': unknown configuration type ' stype '...']);
		out = [];
		return;
    end
