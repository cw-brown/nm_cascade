%%
clear; clc; close all;
fmin = 1e1;
fmax = 1e5;
nfreqs = 200;
freqs = linspace(fmin, fmax, nfreqs) / fmax;

[z, p, k] = butter(9, 2e3/(fmax), 's');
comp = zpk(z, p, k);
h = frd(comp, freqs);

%%
sz = [1 2 1 2];
networks = fpg(sz);
nvar = 13*sum((networks.^2+networks)/2);
x = rand(1, nvar);
obj = @(x, xdata)synthobj(x, sz, xdata);

ydata = db(h.ResponseData(:)');

%%
lb = zeros(1, nvar);
ub = 1e3*ones(1, nvar);

options = optimoptions("lsqcurvefit", "Display", "final-detailed", "PlotFcn", {"optimplotfval", "optimplotx"}, "UseParallel", true);
options.ConstraintTolerance = 1e-9;
options.MaxFunctionEvaluations = 2.5e4;
[result, fval] = lsqcurvefit(obj, x, freqs, ydata, lb, ub, [], [], [], [], [], options);

%%
s_param = cell(1, length(networks));
st = 1;
for ii = 1:length(networks)
    nvar = 13*(networks(ii)^2+networks(ii))/2;
    g = mimotm(result(st:st+nvar-1), networks(ii));
    s_param{ii} = freqresp(g, freqs);
    figure;
    rfplot(sparameters(s_param{ii}, freqs));
    xscale("log");
end
s = l2casc(s_param, freqs, sz);
s = sparameters(s, freqs);
figure;
rfplot(s, 1, 2);
hold on;
grid on;
xscale("log");
rfplot(sparameters(h.ResponseData, freqs));