close all; clear; clc
%% Multi-layer black box and geometry optimizer
sz = [2, 1, 1, 2];
networks = fpg(sz);
nvar = 11*sum(networks.^2+networks)/2;
freqs = logspace(-2, 2, 200);

% Make a sample system to match against
filt = rss(5, 2, 2);
e = getPeakGain(filt);
while e > 1    
    filt = rss(5, 2, 2);
    e = getPeakGain(filt);
end 
filt(1, 2) = filt(2, 1);
f = frd(filt, freqs, 'FrequencyUnit', 'Hz');

option = 'db';

switch option
    case 'db'
        err = db(reshape(f.ResponseData, 1, []));
        plot(freqs, db(reshape(f.ResponseData(1,1,:),1,[])), freqs, db(reshape(f.ResponseData(1,2,:),1,[])), freqs, db(reshape(f.ResponseData(2,1,:),1,[])), freqs, db(reshape(f.ResponseData(2,2,:),1,[])));
        xscale('log'); title('Response Curve'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        legend('dB(S_1_1)', 'dB(S_1_2)', 'dB(S_2_1)', 'dB(S_2_2)'); grid on;
    case 'phase' 
    case 'dbphase'
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
            title(['S_' num2str(col) '_' num2str(row)]);
        end
    case 'phase'
    case 'dbphase'
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
            f = reshape(db(F.ResponseData), 1, []);
        case 'phase'
        case 'dbphase'
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
        g = G{ii};
        % [nu, ny] = iosize(g);
        % H = [g; eye(nu)];
        % Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        % c(ii) = getSectorIndex(H, Q) - (1 - eps^2); % Gain restraint
        c(ii) = getPeakGain(g) - (1-eps^2);
    end
end