%% Optimization Sheet
order = 8;
nvar = order*3;
freqs = logspace(1, 4, 150);
filt = rffilter("FilterOrder", 9, "FilterType", "Butterworth", "StopbandFrequency", 1e3, "PassbandFrequency", 2.5e3);
sfilt = sparameters(filt, freqs);
err = sfilt.Parameters(1, 2, :);

lb = zeros(1, nvar);
ub = 1e-2*ones(1, nvar);
stx = rand(1, nvar);

options = optimoptions("fmincon", "Display", "iter");
obj = @(x)synthesisoptim(x, freqs, err, order);
result = fmincon(obj, stx, [], [], [], [], lb, ub, [], options);
rfplot(sparameters(param2s(result, freqs, order), freqs), 1, 2);
hold on;
rfplot(sfilt, 1, 2);