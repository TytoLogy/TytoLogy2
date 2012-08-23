% HPSearch2_Closing.m
%------------------------------------------------------------------------
% 
% Script that runs just before HPSearch2 is closed. 
% This script is called from CloseRequestFcn of HPSearch2.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Originally Written (HPSearch): 2009-2011 by SJS
% Renamed Version Created (HPSearch2_Closing): 20 February 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

% terminate TDT before closing the GUI
if ~isempty(handles.indev) && ~isempty(handles.outdev) && ...
   ~isempty(handles.zBUS) && ~isempty(handles.PA5L) && ~isempty(handles.PA5R)

   [ tmphandles, tmpflag ] = HPSearch2_TDTclose(handles.h2.config, ...
       handles.indev, handles.outdev, handles.zBUS, handles.PA5L, handles.PA5R);

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



