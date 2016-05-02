function [data, datainfo] = HPSearch2c_readdat2(datafile)
%------------------------------------------------------------------------
% [data, datainfo] = HPSearch2c_readdat2.m(varargin)
%------------------------------------------------------------------------
% 
% Script for reading HPSearch2b binary file. 
%
%------------------------------------------------------------------------
%  Output arguments:
%   data        cell struct array containing analog data
%   datainfo    structure containing header info
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida 
%   go.ashida@uni-oldenburg.de
%------------------------------------------------------------------------
% Created (HPSearch2a_readdat2): Aug 2012 by GA
% Adopted for HPSearch2b (HPSearch2b_readdat2): Nov 2012 by GA
% Adopted for HPSearch2c (HPSearch2c_readdat2): Jan 2015 by GA 
% (no major changes to the code have been made from 2b, only file name)
%------------------------------------------------------------------------
%  based on readHPdata.m, readHPDataFileHeader.m, and 
%   readTrialData.m written by Sharad Shanbhag
%------------------------------------------------------------------------

data = [];
datau = [];
datainfo = struct;

%-------------------------
% file open
%-------------------------

% if datafile is specified, check if it exists
if nargin > 0
    if ~exist(datafile,'file')
        warning([mfilename ' : ' datafile ' not found']); 
    end
else
    datafile = [];
end

% if datafile is not specified, ask user which file to read 
if isempty(datafile)
    [datafile, datapath] = uigetfile('*.dat2','Select HPSearch2c binary data file to read');
    if datafile == 0
        disp('Data reading cancelled.')
        return;
    end
    datafile = fullfile(datapath, datafile);
end

% open binary file
fp = fopen(datafile, 'r');

% check if file has been opened properly 
if fp==-1
    warndlg([mfilename ' : file opening error : ' datafile]);
    return; 
end

%-------------------------
% read the header part
%-------------------------
readheader = 1;  % flag for reading header

while readheader
    % read data
    [d, t, n] = TytoLogy2_readbinary(fp);

    % assign data to the field n of the datainfo structure 
    if ~strcmp(n, '???') && ~strcmp(t, 'err')
        s = sprintf('datainfo.%s = d;', n);
        eval(s);
    end

    % check the ending of the header part
    if strcmp(t, 'string')
        if strcmp(d, 'DATA_START'); 
            readheader = 0;  % end of header
        end
    end
end

%-------------------------
% get rep and trial numbers
%-------------------------
if isfield(datainfo,'stimcache')
    [nreps, ntrials] = size(datainfo.stimcache.trialRandomSequence);
elseif isfield(datainfo,'clickcache')
    [nreps, ntrials] = size(datainfo.clickcache.trialRandomSequence);
else
    warning([mfilename ' : rep/trial numbers cannot be determined : ' datafile]);
    return; 
end

% total number of stimlus combinations
nstims = nreps * ntrials;
disp(sprintf('resp=%d, trials=%d, total=%d',nreps, ntrials, nstims)); 

% allocate cell struct array
data = cell(nstims,1);
datau = cell(nstims,1);

%-------------------------
% read the data part
%-------------------------
readdata = 1;
sindex = 0;

while readdata && ~feof(fp) && sindex < nstims

    sindex = sindex+1;
    readflag = 1;

    while readflag 

        % assuming 'datatraceu' comes last 
        [d, t, n] = TytoLogy2_readbinary(fp);

        % assign data to the field n of the datainfo structure 
        if ~strcmp(n, '???') && ~strcmp(t, 'err')
            s = sprintf('data{%d}.%s = d;', sindex, n);
            eval(s);
        end

        % check the ending of each stim
        if strcmp(n, 'datatraceu'); 
            readflag = 0;  
        end

        % check the ending of the data part
        if strcmp(t, 'string')
            if strcmp(d, 'DATA_END'); 
                readdata = 0; 
                readflag = 0;
            end
        end

    end

end

if sindex < nstims % incomplete data
    datainfo.complete = 0;
else
    datainfo.complete = 1;
end

if readdata 
    datainfo.nread = sindex;
else  % if hit the 'DATA_END' string, the last count is discarded
    datainfo.nread = sindex-1;
end

%-------------------------
% read the footer part
%-------------------------
readfooter = 1;  % flag for reading header

while readfooter
    % read data
    [d, t, n] = TytoLogy2_readbinary(fp);

    % assign data to the field n of the datainfo structure 
    if ~strcmp(n, '???') && ~strcmp(t, 'err')
        s = sprintf('datainfo.%s = d;', n);
        eval(s);
    end

    % check the ending of the file
    if feof(fp) 
        readfooter = 0; 
    end
end

%-------------------------
% file close
%-------------------------
fclose(fp);

