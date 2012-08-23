function [name, os_type] = username2
%------------------------------------------------------------------------
% [name, os_type] = username2
%------------------------------------------------------------------------
% TytoLogyTools toolbox
%------------------------------------------------------------------------
% 
% returns system username and os type 
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	none
% 
% Output Arguments:
% 	name		operating system-defined user name
%	os_type	operating system name
%------------------------------------------------------------------------
% See also: computer, system, echo
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag & Go Ashida
%	sharad.shanbhag@einstein.yu.edu
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 2 December, 2009 (SJS)
%
% Revisions:
%   06 June 2012: added 'PCWIN64' (GA) 
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------


os_type = computer;
switch os_type
	case {'PCWIN', 'PCWIN64'}	
		[status, name] = system('echo %UserName%');
		name = name(1:end-1);
		
	case {'MAC', 'GLNXA64'}
		[status, name] = system('whoami');

	otherwise
		error([mfilename ': ' os_type ' is unknown computer'])
end


