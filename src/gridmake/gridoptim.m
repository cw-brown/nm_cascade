clear; clc; close all;
gridsize = 9;
stx = randi([0, 1], 1, gridsize^2);
n = 2;
sfreq = 1;
efreq = 4;
nfreq = 100;

% Determines how to fit the curves
match = 'db';

% make a desired curve first for verification purposes
s = gridmake(gridsize, stx, n, 'desired', 0, sfreq, efreq, nfreq);
figure;
rfplot(s);

% desired multicurve output
obj = @(x, xdata)gridobj(x, gridsize, n, sfreq, efreq, nfreq, s, match, xdata);
lb = zeros(1, gridsize^2);
ub = ones(1, gridsize^2);
% rx = randi([0, 1], 1, gridsize^2);
rx = zeros(1, gridsize^2);

switch match
    case {'db', 'phase'}
        goal = zeros(1, n^2);
        weight = 1*ones(1, n^2);
    case 'dbphase'
        goal = 1*ones(1, 2*n^2);
        weight = ones(1, 2*n^2);
end
% 
% options = optimoptions('fgoalattain', 'Display', 'iter', 'PlotFcn', {'optimplotx', 'optimplotfval'});
% options.UseParallel = true;
% options.EqualityGoalCount = length(goal);
% [result, fval, gamma, flag, output] = fgoalattain(obj, rx, goal, weight, [], [], [], [], lb, ub, [], options);
% 
% options = optimoptions('fminimax', 'Display', 'iter', 'PlotFcn', 'optimplotx', 'UseParallel', true);
% result = fminimax(obj, rx, [], [], [], [], [], ub, [], options);

options = optimoptions('lsqcurvefit', 'Display', 'iter', 'UseParallel', true);
options.FunctionTolerance = 0;
result = lsqcurvefit(obj, rx, 1:nfreq, reshape(db(s.Parameters), 1, []), [], [], options);

%%
sfinal = gridmake(gridsize, round(result), n, 'output', 0, sfreq, efreq, nfreq);
figure
for ii = 1:n^2
    [row, col] = ind2sub([n, n], ii);
    subplot(n, n, ii);
    rfplot(sfinal, col, row);
    hold on;
    rfplot(s, col, row);
    hold off;
end


