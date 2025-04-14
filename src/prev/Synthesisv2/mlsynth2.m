%% Circuit test
clear; clc; close all;
%% Circuit 1
cir1 = circuit('Circuit1');
nelem = 2;
stx = rand(1, nelem);
add(cir1, [1 2], capacitor(stx(1)));
setports(cir1, [1, 3], [2, 3]);

freqs = linspace(eps, 1, 100);
s1 = sparameters(cir1, freqs); figure;
plot(freqs, db(squeeze(s1.Parameters(1,1,:))), freqs, db(squeeze(s1.Parameters(1,2,:))), ...
    freqs, db(squeeze(s1.Parameters(2,1,:))), freqs, db(squeeze(s1.Parameters(2,2,:)))); grid on;
legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Circuit 1');

%% Circuit 2
cir2 = circuit('Circuit1');
add(cir2, [1 2], inductor(stx(2)));
setports(cir2, [1, 3], [2, 3]);

s2 = sparameters(cir2, freqs); figure;
plot(freqs, db(squeeze(s2.Parameters(1,1,:))), freqs, db(squeeze(s2.Parameters(1,2,:))), ...
    freqs, db(squeeze(s2.Parameters(2,1,:))), freqs, db(squeeze(s2.Parameters(2,2,:)))); grid on;
legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Circuit 2');

%% Cascaded
s = cascadesparams(s1, s2);
figure;
plot(freqs, db(squeeze(s.Parameters(1,1,:))), freqs, db(squeeze(s.Parameters(1,2,:))), ...
    freqs, db(squeeze(s.Parameters(2,1,:))), freqs, db(squeeze(s.Parameters(2,2,:)))); grid on;
legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Cascaded Network');

%% Optimize using TSC
sz = [1, 2, 1, 2];
networks = fpg(sz);
% err = [squeeze(abs(s.Parameters(1, 1, :))) ...
%        squeeze(abs(s.Parameters(1, 2, :))) ...
%        squeeze(abs(s.Parameters(2, 2, :))) ...
%        squeeze(angle(s.Parameters(1, 1, :))) ...
%        squeeze(angle(s.Parameters(1, 2, :))) ...
%        squeeze(angle(s.Parameters(2, 2, :)))];
err = [squeeze(abs(s.Parameters(1, 1, :)))' ...
       squeeze(abs(s.Parameters(1, 2, :)))' ...
       squeeze(abs(s.Parameters(2, 2, :)))' ...
       squeeze(angle(s.Parameters(1, 1, :)))' ...
       squeeze(angle(s.Parameters(1, 2, :)))' ...
       squeeze(angle(s.Parameters(2, 2, :)))'];
% err = [squeeze(abs(s.Parameters(1,1,:)))'...
%        squeeze(abs(s.Parameters(1,2,:)))'...
%        squeeze(abs(s.Parameters(2,2,:)))'];

% obj = @(x, xdata) synobj(x, sz, xdata);
obj = @(x) synobj(x, sz, freqs, err);
constr = @(x) synconstr(x, sz);

nvar = 2*sum(networks.^2+networks)/2;
% nvar = 4;
stx = 2*rand(1,nvar)-1;

ub = ones(1, nvar);
% lb = zeros(1, nvar);
lb = -ub;

% options = optimoptions("lsqcurvefit","UseParallel",true,"PlotFcn",...
%     ["optimplotx","optimplotfval","optimplotfirstorderopt"],...
%     "MaxFunctionEvaluations",3e4,"Display","iter",...
%     "StepTolerance",eps);
% [solution,objectiveValue] = lsqcurvefit(obj,stx,freqs,err,lb,ub,[],[], ...
%     [],[],constr,options);
options = optimoptions("fmincon","Display","iter","UseParallel",true,...
    "PlotFcn","optimplot");
solution = fmincon(obj,stx,[],[],[],[],lb,ub,constr,options);

%% Plot the results
G = casctran(solution, sz);
S1 = sparameters(freqresp(G{1}, freqs), freqs);
S2 = sparameters(freqresp(G{2}, freqs), freqs);
F = cascadesparams(S1, S2);
% H = tsc(G, sz);
% F = frd(H, freqs, 'FrequencyUnit', 'Hz');
figure;
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, reshape(db(s.Parameters(row, col, :)), 1, []), freqs, reshape(db(F.Parameters(row, col, :)), 1, []));
    xscale('linear'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    % legend('Input', 'Synthesis');
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
end
figure;
for ii = 1:sz(1)*sz(2)
    subplot(sz(1), sz(2), ii);
    T = sparameters(freqresp(G{ii}, freqs), freqs);
    rfplot(T);
end