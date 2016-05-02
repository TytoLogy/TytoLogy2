% HPSearch2c_Closing.m
%------------------------------------------------------------------------
% 
% Script that runs just before HPSearch2c is closed. 
% This script is called from CloseRequestFcn of HPSearch2c.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   go.ashida@uni-oldenburg.de
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version Written (HPSearch): 2009-2011 by SJS
% Upgraded Version Created (HPSearch2_Closing): 20 February 2012 by GA
% Adopted for HPSearch2a (HPSearch2a_Closing): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_Closing): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_Closing): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------

% terminate TDT before closing the GUI
if ~isempty(handles.indev) && ~isempty(handles.outdev) && ...
   ~isempty(handles.zBUS) && ~isempty(handles.PA5L) && ~isempty(handles.PA5R)

   [ tmphandles, tmpflag ] = HPSearch2c_TDTclose(handles.h2.config, ...
        handles.indev, handles.outdev, handles.zBUS, ...
        handles.PA5L, handles.PA5R);

    if tmpflag > 0  % TDT hardware has been successfully terminated
        disp([mfilename ': TDT hardware has been successfully terminated'])
        handles.indev = tmphandles.indev;
        handles.outdev = tmphandles.outdev;
        handles.zBUS = tmphandles.zBUS;
        handles.PA5L = tmphandles.PA5L;
        handles.PA5R = tmphandles.PA5R;       
        guidata(hObject, handles);
    else
        disp([mfilename ': TDT was already stopped, or failed to stop TDT'])
    end
end

