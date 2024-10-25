%% 1x2 Test
clear; clc; close all;

sz = [1 2 1 2];
networks = fpg(sz);
nvar = 6*sum(networks.^2+networks)/2;
x = rand(1, nvar);

freqmin = 0;
freqmax = 1e9;
freqs = linspace(freqmin, freqmax, nvar^2/8) / freqmax;

% [z, p, k] = butter(3, 2.5e3/freqmax, 's');
% filt = zpk(z, p, k);
% filt = rss(7);
filt = tf([1 1], [1 2]);
resp = freqresp(filt, freqs);
err = db(resp(:)');

%%
obj = @(x, xdata)synthobj(x, sz, xdata);
constr = @(x)synthconstr(x, sz);

lb = -ones(1, nvar);
ub = ones(1, nvar);
options = optimoptions("lsqcurvefit", "Display", "iter-detailed", "PlotFcn", {'optimplotx', 'optimplotfval'}, 'UseParallel', true);
options.MaxFunctionEvaluations = 2.5e4;
options.ConstraintTolerance = 1e-7;
options.Algorithm = "interior-point";
result = lsqcurvefit(obj, x, freqs, err, lb, ub, [], [], [], [], constr, options);

%%
figure;
H = casctran(result, sz);
G = tsc(H, sz);
J = sparameters(freqresp(G, freqs), freqs);
rfplot(J, 1, 2);
hold on;
xscale("log");
rfplot(sparameters(resp, freqs));

%%
for ii = 1:length(H)
    M = sparameters(freqresp(H{ii}, freqs), freqs);
    figure;
    rfplot(M);
    xscale("log");
end

Q = [0 -1; -1 0];
[W1, W2] = getQData(Q);
pidx = norm((W1'*[G(1,2);1])/(W2'*[G(1,2);1]), Inf);
