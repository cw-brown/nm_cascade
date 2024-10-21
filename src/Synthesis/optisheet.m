%% 1x2 Test
clear; clc; close all;

sz = [1 2 1 2];
networks = fpg(sz);
nvar = 7*sum(networks.^2+networks)/2;
x = rand(1, nvar);

freqmin = 1e1;
freqmax = 1e4;
freqs = linspace(freqmin, freqmax, nvar) / freqmax;

[z, p, k] = butter(3, 2.5e2/freqmax, 's');
filt = zpk(z, p, k);
% filt = rss(7);
resp = freqresp(filt, freqs);
err = db(resp(:)');

%%
obj = @(x, xdata)synthobj(x, sz, xdata);
constr = @(x)synthconstr(x, sz);

lb = -ones(1, nvar);
ub = ones(1, nvar);
options = optimoptions("lsqcurvefit", "Display", "iter", "PlotFcn", {'optimplotx', 'optimplotfval'}, 'UseParallel', true);
options.MaxFunctionEvaluations = 2.5e4;
result = lsqcurvefit(obj, x, freqs, err, lb, ub, [], [], [], [], constr, options);

%%
figure;
H = casctran(result, sz);
G = tsc(H, sz);
rfplot(sparameters(freqresp(G, freqs), freqs), 1, 2);
hold on;
xscale("log");
rfplot(sparameters(resp, freqs));

%%
for ii = 1:length(H)
    figure;
    rfplot(sparameters(freqresp(H{ii}, freqs), freqs));
    xscale("log");
end