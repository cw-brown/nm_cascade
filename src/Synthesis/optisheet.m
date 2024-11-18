%% 1x2 Test
clear; clc; close all;

rng(12345);

sz = [2 1 1 2];
networks = fpg(sz);
nvar = 7*sum(networks.^2+networks)/2;
stx = rand(1, nvar);

freqmin = 0;
freqmax = 1e9;
freqs = linspace(freqmin, freqmax, nvar)/freqmax;

% [z, p, k] = butter(3, 2.5e3/freqmax, 's');
% filt = zpk(z, p, k);
% filt = rss(7);
% filt = tf([1 1], [1 2]);
filt = zpk([-0.2+.1j, -0.2-.1j], [-.6+2j, -.6-2j, -0.6], 0.85);
% filt = tf(0.2);
resp = freqresp(filt, freqs);
err = db(resp(:)');

%%
obj = @(x, xdata)synthobj(x, sz, xdata);
constr = @(x)synthconstr(x, sz, freqs);

lb = -1e2*ones(1, nvar);
ub = 1e2*ones(1, nvar);
options = optimoptions("lsqcurvefit", "Display", "iter-detailed", "PlotFcn", {'optimplotx', 'optimplotfval', 'optimplotfirstorderopt', 'optimplotstepsize'}, 'UseParallel', true);
options.MaxFunctionEvaluations = 2.5e4;
result = lsqcurvefit(obj, stx, freqs, err, [], [], [], [], [], [], constr, options);

%%
figure;
H = casctran(result, sz);
G = tsc(H, sz);
J = sparameters(freqresp(G, freqs), freqs);
rfplot(J, 1, 2);
hold on;
xscale("log");
rfplot(sparameters(resp, freqs));

Z = sqrt(50)*eye(2)*(eye(2)+G)/(eye(2)-G)*eye(2)*sqrt(50);
F = freqresp(Z, freqs);
figure;
subplot(1, 2, 1);
plot(freqs, gradient(imag(reshape(F(1,1,:), 1, [])), freqs(2)-freqs(1)));
subplot(1, 2, 2);
plot(freqs, gradient(imag(reshape(F(2,2,:), 1, [])), freqs(2)-freqs(1)));

%%
for ii = 1:length(H)
    M = sparameters(freqresp(H{ii}, freqs), freqs);
    figure;
    rfplot(M);
    xscale("log");
end

%% Gain and Passivity
for ii = 1:length(H)
    [nu, ny] = iosize(H{ii});
    Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
    G = [H{ii}; eye(nu)];
    [W1, W2] = getQData(Q);
    a = norm((W1'*G)/(W2'*G), Inf);
    Q = [zeros(nu), -eye(nu); -eye(ny), zeros(ny)];
    [W1, W2] = getQData(Q);
    b = norm((W1'*G)/(W2'*G), Inf);
    [a, b]
end

%% Impedance transform
Z = cell(1, length(H));
for ii = 1:length(Z)
    figure;
    g = H{ii};
    [nu, ~] = iosize(g);
    I = eye(nu);
    Z{ii} = sqrt(50)*I*(I+g)/(I-g)*sqrt(50)*I;
    F = frd(Z{ii}, freqs);
    refplot = reshape(1:nu^2, nu, nu);
    for jj = 1:nu
    for kk = 1:nu
        subplot(nu, nu, refplot(jj, kk));
        D = F.ResponseData(jj, kk, :);
        plot(freqs, gradient(imag(D(:)), freqs(2)-freqs(1)));
    end
    end
end
