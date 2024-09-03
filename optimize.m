%% Optimization worksheet
sz = [2 2, 1 4];
freqs = linspace(.1e9, 3e9, 25);
ports = fpg(sz); ports = ports(2:end-1);
nvars = 2*sum((ports.^2+ports)/2)*length(freqs);

%% Error function for matching waves
filt = rffilter('FilterType', 'Butterworth', 'ResponseType', 'Lowpass', 'PassbandFrequency', .6e9, 'StopbandFrequency', 1.1e9);
filtS = sparameters(filt, freqs);
errfunc = db(filtS.Parameters(1, 2, :));
errfunc = errfunc(:)';

%% Optimization
obj = @(x)cascadeobj(x, freqs, sz, errfunc);
constr = @(x)lprestr(x, freqs, sz);
options = optimoptions("fmincon", "Display", "iter", "MaxFunctionEvaluations", 1e5, "PlotFcn", {'optimplotfval', 'optimplotconstrviolation'}, "UseParallel", true);
lb = -ones(1, nvars); ub = ones(1, nvars);
result = fmincon(obj, rand(1, nvars), [], [], [], [], lb, ub, constr, options);
s_params = l2casc(num2sparam(result, freqs, sz), freqs, sz);
figure;
rfplot(sparameters(s_params, freqs), 1, 2);
hold on;
rfplot(filtS, 1, 2);