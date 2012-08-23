function out = HPSearch2_datetime(f,t)
%------------------------------------------------------------------------
% HPSearch2_DateTime.m
%------------------------------------------------------------------------
% 
% Script to generate date and time strings for HPSearch2
%
% For backward compatibility, this script converts HPsearch2 type 
% date/time strings into HPSearch type strings
%
%------------------------------------------------------------------------
%  IN: f = format ('date' or 'time')
%      t = HPSearch2 type date/time string 
%        if t is empty, then this function returns HPSearch2 type string
%        otherwise this function converts HPSearch2 type string into 
%        HPSearch type string
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 26 October, 2011 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

f = lower(f);

if ~exist('t')  % generating HPSearch2 string

 if strcmp(f,'date')   
     out = datestr(now,29); % 'yyyy-mm-dd' format
 elseif strcmp(f,'time')
     out = datestr(now,13); % 'HH:MM:SS' format
 end

else % converting to HPSearch string

 if strcmp(f,'date')   % 'yyyy-mm-dd' into 'dd-mmm-yyyy'
     out =  datestr( datenum(t,'yyyy-mm-dd'),1 ); 
 elseif strcmp(f,'time')
     out = strcat(t,'.00'); % 'HH:MM:SS(%.2f)' format
 end
    
end    
