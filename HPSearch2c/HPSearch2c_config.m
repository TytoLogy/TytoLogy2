function out = HPSearch2c_config(stype)
%------------------------------------------------------------------------
% out = HPSearch2c_config(stype)
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
%  Go Ashida, Sharad Shanbhag & Fanny Cazettes
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%   fanny.cazettes@phd.einstein.yu.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch_init): 2009-2010 by SJS
% Upgraded Version Written (HPSearch2_config): 2011-2012 by GA
% Code for the Medusa added: 2012 by FC
% Adopted for HPSearch2a (HPSearch2a_config): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_config): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_Opening): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file names)
%------------------------------------------------------------------------

%----------------------------------------------------------------------
% check input argument
%----------------------------------------------------------------------
if ~nargin
	stype = 'default';
end
stype = upper(stype);

%----------------------------------------------------------------------
% return desired information
%----------------------------------------------------------------------
switch stype
    case 'NO_TDT'
        out.CONFIGNAME = stype;
        out.ioFunc = @HPSearch2c_NoTDT_spikeio;
        out.TDTsetFunc = @HPSearch2c_NoTDT_settings;
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
        out.ioFunc = @HPSearch2c_spikeio;
        out.TDTsetFunc = @HPSearch2c_RX8settings;
        out.setattenFunc = @PA5setatten;
        % input device
        out.indev.hardware = 'RX8';
        out.indev.Fs = 50000;
        out.indev.Circuit_Path = 'C:\TytoLogy2\toolbox2\TDTcircuits\'; 
        out.indev.Circuit_Name = 'RX8_3_SingleChannelFiltUnfilt'; % for Carr lab
        out.indev.Dnum = 1; % device number
%        out.indev.Circuit_Name = 'RX8_2_SingleChannelFiltUnfilt'; % for Pena Lab
%        out.indev.Dnum = 2; % device number % for Pena Lab
        % output device
        out.outdev.hardware = 'RX8'; % same device used for both input and output
        out.outdev.Fs = 50000;
        out.outdev.Circuit_Path = ''; 
        out.outdev.Circuit_Name = '';
        out.outdev.Dnum = 1; % device number
        return;

    case 'RX6_50K' % use RX6 for both input and output
        out.CONFIGNAME = stype;
        out.ioFunc = @HPSearch2c_spikeio;
        out.TDTsetFunc = @HPSearch2c_RX6settings;
        out.setattenFunc = @PA5setatten;
        % input device
        out.indev.hardware = 'RX6';
        out.indev.Fs = 50000;
        out.indev.Circuit_Path = 'C:\TytoLogy2\toolbox2\TDTcircuits\';
        out.indev.Circuit_Name = 'RX6_50k_SingleChannelFiltUnfilt';
        out.indev.Dnum = 1; % device number
        % output device
        out.outdev.hardware = 'RX6'; % same device used for both input and output
        out.outdev.Fs = 50000;
        out.outdev.Circuit_Path = '';
        out.outdev.Circuit_Name = '';
        out.outdev.Dnum = 1; % device number
        return;

    % RX5 + medusa for input & RX8(2) for output
    case 'MEDUSA' % caution: not fully implemented or checked
        out.CONFIGNAME = stype;
        out.ioFunc = @HPSearch2c_medusarec2_1chan; 
        out.TDTsetFunc = @HPSearch2c_medusasettings;  
        out.setattenFunc = @PA5setatten;
        % input device
        out.indev.hardware = 'MEDUSA';
        out.indev.Fs = 25000;
        out.indev.Circuit_Path = 'C:\TytoLogy\toolbox\TDT\Circuits\RX5\';
        out.indev.Circuit_Name = 'RX5_1ChannelAcquire_zBus';
        out.indev.Dnum = 1; % device number
        % output device
        out.outdev.hardware = 'RX8';
        out.outdev.Fs = 50000;
        out.outdev.Circuit_Path = 'C:\TytoLogy\toolbox\TDT\Circuits\RX8_2\50KHz\';
        out.outdev.Circuit_Name = 'RX8_2_BinauralOutput_zBus';
        out.outdev.Dnum = 2; % device number
        return;

    % if the argument is not known...
    otherwise
		disp([mfilename ': unknown configuration type ' stype '...']);
		out = [];
		return;
end
