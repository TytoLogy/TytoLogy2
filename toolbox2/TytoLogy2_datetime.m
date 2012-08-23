function out = TytoLogy2_datetime(f)
%------------------------------------------------------------------------
% TytoLogy_DateTime.m
%------------------------------------------------------------------------
%
% Script to generate date and time strings for TytoLogy2 scripts
%
%------------------------------------------------------------------------
%  Input Argument: 
%   f = format ('date' or 'time')
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version (HPSearch2_datetime) : October 2011 by GA
% Generalized Version (TytoLogy2_datetime) : May 2012 by GA
%------------------------------------------------------------------------

f = lower(f);

if strcmp(f,'date')   
    out = datestr(now,29); % 'yyyy-mm-dd' format
elseif strcmp(f,'time')
    out = datestr(now,13); % 'HH:MM:SS' format
end

