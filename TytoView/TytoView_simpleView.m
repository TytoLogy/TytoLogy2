function TytoView_simpleView(filename)
%------------------------------------------------------------------------
% TytoView_simpleView.m
%------------------------------------------------------------------------
%  For plotting Curve (and Click) data collected by TytoLogy2
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Created: 18 March, 2012 by GA
%
% Revisions: 
% 
%------------------------------------------------------------------------

if nargin < 1
    % if no file name provided, then ask user
    [fname, fpath] = ...
        uigetfile('*.mat', 'Load HPSearch2 data file...');
    if fname == 0 % return if user hits CANCEL button
        disp('loading cancelled...');
        return;
    end

else
    fpath = pwd;
    fname = filename;
end

% load data
disp(['Loading HPSearch2 data from ' fname])
c = load(fullfile(fpath, fname));

% check if loaded data is a structure
if ~isstruct(c)
    warndlg([fname '--- invalid TytoLogy2 data file'], 'TytoView error');
    return; 
end

% check whether this is a curve file or click file
if isfield(c,'curvedata') && isfield(c,'curvesettings')

    if isstruct(c.curvedata) && isstruct(c.curvesettings)
        TytoView_simpleplot(c.curvedata, c.curvesettings); 
    else
        warndlg([fname '--- curve data broken'], 'TytoView error');
    end

elseif isfield(c,'clickdata') && isfield(c,'clicksettings')

    if isstruct(c.clickdata) && isstruct(c.clicksettings)
        TytoView_clickplot(c.clickdata, c.clicksettings); 
    else
        warndlg([fname '--- click data broken'], 'TytoView error');
    end

else

    warndlg([fname ': data fields do not exist -- invalid TytoLogy2 data file'], 'TytoView error');

end


