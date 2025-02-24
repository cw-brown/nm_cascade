%% Multi-layer black box and geometry optimizer
close all; clear; clc;
sz = [1, 2, 1, 2];
networks = fpg(sz);
nvar = 8*sum(networks.^2+networks)/2;
freqs = logspace(-2, 2, 75);

% Make a sample system to match against
filt = rss(7, 2, 2);
e = getPeakGain(filt);
while e > 1
    filt = rss(7, 2, 2);
    e = getPeakGain(filt);
end
filt(1, 2) = filt(2, 1);
f = frd(filt, freqs, 'FrequencyUnit', 'Hz');

option = 'dbphase';

switch option
    case 'db'
        err = [reshape(abs(f.ResponseData(1, 1, :)), 1, []) ...
               reshape(abs(f.ResponseData(1, 2, :)), 1, []) ...
               reshape(abs(f.ResponseData(2, 2, :)), 1, [])];
        plot(freqs, db(reshape(f.ResponseData(1,1,:),1,[])), freqs, db(reshape(f.ResponseData(1,2,:),1,[])), freqs, db(reshape(f.ResponseData(2,1,:),1,[])), freqs, db(reshape(f.ResponseData(2,2,:),1,[])));
        xscale('log'); title('Response Curve'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        legend('dB(S_1_1)', 'dB(S_1_2)', 'dB(S_2_1)', 'dB(S_2_2)'); grid on;
    case 'phase' 
        err = [reshape(angle(f.ResponseData(1, 1, :)), 1, []) ...
               reshape(angle(f.ResponseData(1, 2, :)), 1, []) ...
               reshape(angle(f.ResponseData(2, 2, :)), 1, [])];
        plot(freqs, angle(reshape(f.ResponseData(1,1,:),1,[])), freqs, angle(reshape(f.ResponseData(1,2,:),1,[])), freqs, angle(reshape(f.ResponseData(2,1,:),1,[])), freqs, angle(reshape(f.ResponseData(2,2,:),1,[])));
        xscale('log'); title('Response Curve'); xlabel('Frequency (Hz)'); ylabel('Phase');
        legend('dB(S_1_1)', 'dB(S_1_2)', 'dB(S_2_1)', 'dB(S_2_2)'); grid on;
    case 'dbphase'
        err = [reshape(abs(f.ResponseData(1, 1, :)), 1, []) ...
               reshape(abs(f.ResponseData(1, 2, :)), 1, []) ...
               reshape(abs(f.ResponseData(2, 2, :)), 1, []), ...
               reshape(angle(f.ResponseData(1, 1, :)), 1, []), ...
               reshape(angle(f.ResponseData(1, 2, :)), 1, []), ...
               reshape(angle(f.ResponseData(2, 2, :)), 1, [])];
        subplot(2, 1, 1);
        plot(freqs, db(reshape(f.ResponseData(1,1,:),1,[])), freqs, db(reshape(f.ResponseData(1,2,:),1,[])), freqs, db(reshape(f.ResponseData(2,1,:),1,[])), freqs, db(reshape(f.ResponseData(2,2,:),1,[])));
        xscale('log'); title('Response Curve'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        legend('dB(S_1_1)', 'dB(S_1_2)', 'dB(S_2_1)', 'dB(S_2_2)'); grid on;
        subplot(2, 1, 2);
        plot(freqs, angle(reshape(f.ResponseData(1,1,:),1,[])), freqs, angle(reshape(f.ResponseData(1,2,:),1,[])), freqs, angle(reshape(f.ResponseData(2,1,:),1,[])), freqs, angle(reshape(f.ResponseData(2,2,:),1,[])));
        xscale('log'); title('Response Curve'); xlabel('Frequency (Hz)'); ylabel('Phase');
        legend('Angle(S_1_1)', 'Angle(S_1_2)', 'Angle(S_2_1)', 'Angle(S_2_2)'); grid on;
    otherwise
        error('Invalid curve fitting option');
end

%%
obj = @(x, xdata) synobj(x, sz, xdata, option);
constr = @(x) synthconstr(x, sz);
stx = rand(1, nvar);
lb = -1e2*ones(1, nvar);
ub = 1e2*ones(1, nvar);
options = optimoptions("lsqcurvefit", "Display", "iter", "PlotFcn", {'optimplotx', 'optimplotfval', 'optimplotfirstorderopt'}, "UseParallel", true);
options.MaxFunctionEvaluations = 5e4;
[result, res, fval, flag, output] = lsqcurvefit(obj, stx, freqs, err, [], [], [], [], [], [], constr, options);

%%
G = casctran(result, sz);
H = tsc(G, sz);
F = frd(H, freqs, 'FrequencyUnit', 'Hz');
figure
switch option
    case 'db'
        for ii = 1:4
            [row, col] = ind2sub([2, 2], ii);
            subplot(2, 2, ii);
            plot(freqs, reshape(db(f.ResponseData(row, col, :)), 1, []), freqs, reshape(db(F.ResponseData(row, col, :)), 1, []));
            xscale('log'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
            legend('Input', 'Synthesis');
            title(['S_' num2str(col) '_' num2str(row)]); grid on;
        end
    case 'phase'
        for ii = 1:4
            [row, col] = ind2sub([2, 2], ii);
            subplot(2, 2, ii);
            plot(freqs, reshape(angle(f.ResponseData(row, col, :)), 1, []), freqs, reshape(angle(F.ResponseData(row, col, :)), 1, []));
            xscale('log'); xlabel('Frequency (Hz)'); ylabel('Phase');
            legend('Input', 'Synthesis');
            title(['S_' num2str(col) '_' num2str(row)]); grid on;
        end
    case 'dbphase'
        for ii = 1:4
            [row, col] = ind2sub([2, 2], ii);
            subplot(2, 2, ii);
            plot(freqs, reshape(db(f.ResponseData(row, col, :)), 1, []), freqs, reshape(db(F.ResponseData(row, col, :)), 1, []));
            xscale('log'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
            legend('Input', 'Synthesis');
            title(['S_' num2str(col) '_' num2str(row)]); grid on;
        end
        figure;
        for ii = 1:4
            [row, col] = ind2sub([2, 2], ii);
            subplot(2, 2, ii);
            plot(freqs, reshape(angle(f.ResponseData(row, col, :)), 1, []), freqs, reshape(angle(F.ResponseData(row, col, :)), 1, []));
            xscale('log'); xlabel('Frequency (Hz)'); ylabel('Phase');
            legend('Input', 'Synthesis');
            title(['S_' num2str(col) '_' num2str(row)]); grid on;
        end
    otherwise
        error('Invalid curve fitting option');
end

%%
figure
for ii = 1:sz(1)*sz(2)
    subplot(sz(1), sz(2), ii);
    T = sparameters(freqresp(G{ii}, freqs), freqs);
    rfplot(T);
    xscale('log');
end

%%
function f = synobj(x, sz, freqs, option)
    G = casctran(x, sz);
    H = tsc(G, sz);
    F = frd(H, freqs, 'FrequencyUnit', 'Hz');
    switch option
        case 'db'
            f = [reshape(abs(F.ResponseData(1, 1, :)), 1, []) ...
                 reshape(abs(F.ResponseData(1, 2, :)), 1, []) ...
                 reshape(abs(F.ResponseData(2, 2, :)), 1, [])];
        case 'phase'
            f = [reshape(angle(F.ResponseData(1, 1, :)), 1, []) ...
                 reshape(angle(F.ResponseData(1, 2, :)), 1, []) ...
                 reshape(angle(F.ResponseData(2, 2, :)), 1, [])];
        case 'dbphase'
            f = [reshape(abs(F.ResponseData(1, 1, :)), 1, []) ...
               reshape(abs(F.ResponseData(1, 2, :)), 1, []) ...
               reshape(abs(F.ResponseData(2, 2, :)), 1, []), ...
               reshape(angle(F.ResponseData(1, 1, :)), 1, []), ...
               reshape(angle(F.ResponseData(1, 2, :)), 1, []), ...
               reshape(angle(F.ResponseData(2, 2, :)), 1, [])];
        otherwise
            error('Invalid curve fitting option');
    end
end

function [c, ceq] = synthconstr(x, sz)
    G = casctran(x, sz);
    n = length(G);
    ceq = zeros(n, 1);
    c = zeros(n, 1);
    for ii = 1:n
        c(ii) = getPeakGain(G{ii}) - (1-eps^2);
    end
end