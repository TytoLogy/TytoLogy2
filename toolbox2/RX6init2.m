function RPstruct = RX6init2(interface, device_num)
%------------------------------------------------------------------------
% RPstruct = RX6init2(interface, dnum)
%------------------------------------------------------------------------
% TDT toolbox
%--------------------------------------------------------------------------
% Initializes and connects to RX6
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	interface		'GB' for gigabit, 'USB' for USB (default = 'GB')
% 	device_num		device ID number, use zBUSMon to verify (default = 1)
% 
% Output Arguments:
% 	RPstruct		TDT toolbox RP control structure, 0 if unsuccessful
%	RPstruct.C		ActiveX control handle
%	RPstruct.handle	figure handle for RPstruct
%
%------------------------------------------------------------------------
% See also: RPload, RPhalt, zBUSinit, RX5init, PA5init
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag & Go Ashida
%	sshanbha@aecom.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 19 August, 2009
%			(modified from RX5init)
%
% Revisions:
%	12 Dec 2011 (GA):
% 		-	changed calls to eliminate use of invoke function 
%------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if input arguments are ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin ~= 2
	disp([mfilename ': using defaults, GB'])
	interface = 'GB';
    device_num = 1;
end

% Make text upper case
interface = upper(interface);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sure input args are in bounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(strcmp(interface, 'GB') | strcmp(interface, 'USB'))
	warning([mfilename ': invalid interface, using GB']);
	interface = 'GB';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create invisible figure for control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RPstruct.handle = figure;
set(RPstruct.handle, 'Visible', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize Device
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create ActiveX control object
RPstruct.C = actxcontrol('RPco.x',[5 5 26 26], RPstruct.handle);

%Clears all the Buffers and circuits on that RP2
%invoke(RPstruct.C, 'ClearCOF');
RPstruct.C.ClearCOF;

%connects RP2 via USB or Xbus given the proper device number
%invoke(RPstruct.C, 'ConnectRX6', interface, device_num);
RPstruct.C.ConnectRX6(interface, device_num);

% Since the device is not started, set status to 0
RPstruct.status = 0;
