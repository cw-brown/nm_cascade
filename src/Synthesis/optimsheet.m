%% Optimization Sheet
close all;
sz = 2;
terms = 7;
nvar = 3*4*terms;
freqs = logspace(1, 6, 15);
filt = rffilter("FilterOrder", 3, "FilterType", "Butterworth", "StopbandFrequency", 1e3, "PassbandFrequency", 2.5e3);
sfilt = sparameters(filt, freqs);
err = sfilt.Parameters(1, 2, :);

lb = -20*ones(1, nvar);
ub = 20*ones(1, nvar);
stx = rand(1, nvar);

%%
options = optimoptions("fmincon", "Display", "iter", "MaxFunctionEvaluations", 5e3);
obj = @(x)synthesisoptim(x, sz, freqs, err, terms);
result = fmincon(obj, stx, [], [], [], [], [], [], [], options);

s = param2s(result, 2, freqs, terms);
s = sparameters(s, freqs);
rfplot(s, 1, 2);
hold on;
rfplot(sfilt, 1, 2);
xscale("log");
