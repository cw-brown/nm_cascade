%%
clear; clc; close all;
fmin = 1e1;
fmax = 1e5;
nfreqs = 200;
freqs = linspace(fmin, fmax, nfreqs) / fmax;

[z, p, k] = butter(3, 2e3/(fmax), 's');
comp = zpk(z, p, k);
h = frd(comp, freqs);

%%
sz = 2;
nvar = 13*(sz^2+sz)/2;
x = rand(1, nvar);
obj = @(x, xdata)synthobj(x, sz, xdata);
constr = @(x)synthconstr(x, sz, freqs);

ydata = db(h.ResponseData(:)');

%%
lb = zeros(1, nvar);
ub = ones(1, nvar);

options = optimoptions("lsqcurvefit", "Display", "iter", "PlotFcn", {"optimplotfval", "optimplotx"}, "UseParallel", true);
options.ConstraintTolerance = 1e-9;
options.MaxFunctionEvaluations = 2.5e4;
[result, fval] = lsqcurvefit(obj, x, freqs, ydata, lb, ub, [], [], [], [], [], options);

%%
g = mimotm(result, sz);
figure;
bode(g(1, 2), freqs);
hold on;
bode(h, freqs);
grid on;