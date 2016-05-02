function [resp, index, respu, nptsu] = HPSearch2c_medusarec2_1chan(stim_lr, inpts, indev, outdev, zdev)
%------------------------------------------------------------------------
% [resp, index, respu, nptsu] = HPSearch2c_medusarec2_1chan(stim_lr, inpts, indev, outdev, zdev)
%------------------------------------------------------------------------
%
% plays stim_lr out headphones, records input spike data on 
% RX5 (medusa), single channel
%
%	NOTE:  performs MINIMAL to NO checks on input variables!!!!
%			Use with caution and attention!
%
%------------------------------------------------------------------------
% Input Arguments:
% 	stim_lr		[2 X N] stereo output signal (row 1 == left, row2 == right)
% 	inpts			number of points to acquire
% 	indev			TDT device interface structure for input
% 	outdev		TDT device interface structure for output
% 	zdev			TDT device interface structure for zBUS
% 
% Output Arguments:
% 	resp			[1 X inpts] input data vector for channel A
%                   (or [1 X index] if something weird happens)
% 	index			number of data points read
%
%   respu           [1 X inpts] input data vector (dummy)
%   nptsu           number of data points read
%   For the moment, respu is just a copy of resp. 
% 
%------------------------------------------------------------------------
% See Also: headphonecal_io, headphone_spikeio
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag, Fanny Cazetts & Go Ashida  
%   sshanbhag@neomed.edu
%   fanny.cazettes@phd.einstein.yu.edu
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Original Version Written (headphonestim_medusarec_1chan): Mar 2010 (SJS) from headphonestim_medusarec.m January, 2009
% Upgraded Version (headphonestim_medusarec2_1chan): Jul 2012 by FC
% Adopted for HPSearch2a (HPSearch2a_medusarec2_ichan): Sep 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_medusarec2_ichan): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_medusarec2_ichan): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

% send reset command (software trigger 3)
RPtrig(outdev, 3);
RPtrig(indev, 3);

% Load output buffer
out_msg = RPwriteV(outdev, 'data_outL', stim_lr(1, :));
out_msg = RPwriteV(outdev, 'data_outR', stim_lr(2, :));

% send the zBustrigA to start acquisition (see circuit for details)
status = zBUStrigA(zdev, 0, 0, 6);

% Main Looping Section
sweep_end = RPfastgettag(outdev, 'SwpEnd');
while(sweep_end == 0)
	sweep_end = RPfastgettag(outdev, 'SwpEnd');
end
sweepCount = RPfastgettag(outdev, 'SwpN');

% Stop Playing and Recording
zBUStrigB(zdev, 0, 0, 6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the data from the buffers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inptsA = inpts;
inptsB = inpts;

% --- channel A
% get the current location in the buffer
index = RPfastgettag(indev, 'mcIndex');

if index < inptsA
	inptsA = index;
end

%reads from the buffer
resp = RPreadV(indev, 'mcData', inptsA);

% --- channel B 
nptsu = RPgettag(indev, 'mcIndex'); % get the current location in the buffer
respu = index; 

% if nptsu < inptsB
% 	inptsB = nptsu;
% end
% %reads unfiltered data from the buffer
% respu = RPreadV(indev, 'mcIndex', inptsB);

