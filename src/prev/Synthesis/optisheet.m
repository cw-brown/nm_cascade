clear; clc; close all;

sz = [2 1 1 2];
networks = fpg(sz);
nvar = 7*sum(networks.^2+networks)/2;
stx = rand(1, nvar);

freqmin = 1e8;
freqmax = 1e9;
freqs = linspace(freqmin, freqmax, nvar);


filt = rss(12);
Q = [1, 0; 0, -1];
H = [filt; 1];
e = getSectorIndex(H, Q);
while e > 1    
    filt = rss(12);
    H = [filt; 1];
    e = getSectorIndex(H, Q);
end
resp = freqresp(filt, freqs);
err = db(resp(:)');

%%
obj = @(x, xdata)synthobj(x, sz, xdata);
constr = @(x)synthconstr(x, sz, freqs);

lb = zeros(1, nvar);
ub = 1e2*ones(1, nvar);
options = optimoptions("lsqcurvefit", "Display", "iter-detailed", "PlotFcn", {'optimplotx', 'optimplotfval', 'optimplotfirstorderopt', 'optimplotstepsize'}, 'UseParallel', true);
options.MaxFunctionEvaluations = 2.5e4;
result = lsqcurvefit(obj, stx, freqs, err, lb, [], [], [], [], [], constr, options);

%%
figure;
H = casctran(result, sz);
G = tsc(H, sz);
J = sparameters(freqresp(G, freqs), freqs);
rfplot(J, 1, 1);
hold on;
xscale("log");
rfplot(sparameters(resp, freqs));
