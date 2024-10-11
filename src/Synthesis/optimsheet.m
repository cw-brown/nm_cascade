%% Optimization Sheet
close all; clear; clc;
sz = [2, 2, 1, 2];
ports = fpg(sz); ports = ports(2:end-1);
nvar = 11 * sum((ports.^2+ports)/2);
freqs = logspace(0, 5, 250);

[z,p,k] = butter(9, 2e2, "s");
filt = zpk(z, p, k);
err = freqresp(filt, freqs);

stx = rand(1, nvar);

%%
obj = @(x)synthesisoptim(x, sz, freqs, err);

ub = 1e12*ones(1, nvar);
lb = ones(1, nvar);

goal = [0, 1];
weight = abs(goal);
options = optimoptions("fgoalattain", "Display", "iter", "UseParallel", true, "PlotFcn", {"optimplotx", 'optimplotfval'});
result = fgoalattain(obj, stx, goal, weight, [], [], [], [], lb, ub, [], options);

%%
figure;
H = param2s(result, sz, freqs);
H = sparameters(H, freqs);
G = sparameters(err, freqs);
rfplot(H);
hold on;
grid on;
xscale("log");
rfplot(G);

