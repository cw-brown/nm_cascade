%% Circuit test
clear; clc; close all;
%% Circuit 1
cir1 = circuit('Circuit1');
add(cir1, [1, 2], capacitor(10e-6));
add(cir1, [2, 3], inductor(1e-6));
add(cir1, [3, 4], inductor(68e-6));
add(cir1, [3, 4], capacitor(22e-6));
add(cir1, [3, 5], capacitor(1e-6));
add(cir1, [4, 6], inductor(22e-6));
setports(cir1, [1, 4], [5, 6]);

freqs = logspace(3, 4, 100);
s1 = sparameters(cir1, freqs);
figure;
plot(freqs, db(squeeze(s1.Parameters(1,1,:))), freqs, db(squeeze(s1.Parameters(1,2,:))), ...
    freqs, db(squeeze(s1.Parameters(2,1,:))), freqs, db(squeeze(s1.Parameters(2,2,:)))); grid on;
legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Circuit 1');

%% Circuit 2
cir2 = circuit('Circuit2');
add(cir2, [1, 2], capacitor(68e-6));
add(cir2, [1, 3], inductor(22e-6));
add(cir2, [1, 3], capacitor(22e-6));
add(cir2, [3, 2], capacitor(10e-6));
add(cir2, [3, 4], inductor(1e-6));
add(cir2, [2, 4], capacitor(68e-6));
setports(cir2, [1, 2], [3, 4]);

s2 = sparameters(cir2, freqs);
figure;
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
err = [squeeze(abs(s.Parameters(1, 1, :))) ...
       squeeze(abs(s.Parameters(1, 2, :))) ...
       squeeze(abs(s.Parameters(2, 2, :)))];

obj = @(x, xdata) synobj(x, sz, xdata);
constr = @(x) synconstr(x, sz);

nvar = 25*sum(networks.^2+networks)/2;
stx = 1e7*rand(1, nvar);

options = optimoptions("lsqcurvefit","UseParallel",true,"PlotFcn",...
    ["optimplotx","optimplotfval","optimplotfirstorderopt"],...
    "MaxFunctionEvaluations",3e4,"TypicalX",repmat(1e6, size(stx)));
[solution,objectiveValue] = lsqcurvefit(obj,stx,freqs,err,[],[],[],[], ...
    [],[],constr,options);

%% Plot the results
G = casctran(solution, sz);
H = tsc(G, sz);
F = frd(H, freqs, 'FrequencyUnit', 'Hz');
figure;
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, reshape(db(s.Parameters(row, col, :)), 1, []), freqs, reshape(db(F.ResponseData(row, col, :)), 1, []));
    xscale('log'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    % legend('Input', 'Synthesis');
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
end
figure;
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, reshape(angle(s.Parameters(row, col, :)), 1, []), freqs, reshape(angle(F.ResponseData(row, col, :)), 1, []));
    xscale('log'); xlabel('Frequency (Hz)'); ylabel('Phase');
    % legend('Input', 'Synthesis');
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
end
figure;
for ii = 1:sz(1)*sz(2)
    subplot(sz(1), sz(2), ii);
    T = sparameters(freqresp(G{ii}, freqs), freqs);
    rfplot(T);
end