function TytoView_clickplot(clickdata, clicksettings)
%------------------------------------------------------------------------
% FOCHS_clickplot.m
%------------------------------------------------------------------------
%  for plotting Click data
%------------------------------------------------------------------------
%  Go Ashida 
%   ashida@umd.edu
%------------------------------------------------------------------------
% Original Version (TytoView_clickplot): March 2012 by GA
% Four-Channel Version (FOCHS_clickplot): May 2012 by GA
%------------------------------------------------------------------------

%----------------------------------------------------------
% extracting data
%----------------------------------------------------------
% extract file name
[pathstr, filestr, extstr] = fileparts(clicksettings.clicksettingsfile);

% loop variables
itd = clickdata.itd_sort;

% calculate mean and std of spike rates 
y = clickdata.fit_amp * 1000; % [mV]
m = mean(y,3);  % average wrt 2nd index (=rep)
s = std(y,1,3); % std wrt 2nd index (=rep)
x = itd(:,1);

% if itd is varies use it for x
if length(itd) > 1
    x1 = x;
    x2 = x;
    x3 = x;
    x4 = x;
else
    x1 = 1;
    x2 = 2;
    x3 = 3;
    x4 = 4;
end

% now plot
figure;
cla;
hold on;
errorbar(x1, m(1,:), s(1,:), 'bo-');
errorbar(x2, m(2,:), s(2,:), 'ro-');
errorbar(x3, m(3,:), s(3,:), 'go-');
errorbar(x4, m(4,:), s(4,:), 'mo-');
hold off;
xlabel('ITD (us)');
ylabel('# amplitude (mV)');
title(filestr);
drawnow;



