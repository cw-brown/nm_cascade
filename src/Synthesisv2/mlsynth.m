close all; clear; clc
%% Multi-layer black box and geometry optimizer
sz = [1, 3, 1, 3];
networks = fpg(sz);
nvar = 5*sum(networks.^2+networks)/2;

freqs = logspace(-2, 2, 100);

% Make a sample system to match against
filt = rss(11, 2, 2);
H = [filt; eye(2)];
Q = [eye(2), zeros(2); zeros(2), -eye(2)];
e = getSectorIndex(H, Q);
while e > 1    
    filt = rss(8, 2, 2);
    H = [filt; eye(2)];
    e = getSectorIndex(H, Q);
end 
filt(1, 2) = filt(2, 1);

f = frd(filt, freqs, 'FrequencyUnit', 'Hz');
plot(freqs, db(reshape(f.ResponseData(1,1,:),1,[])), freqs, db(reshape(f.ResponseData(1,2,:),1,[])), freqs, db(reshape(f.ResponseData(2,1,:),1,[])), freqs, db(reshape(f.ResponseData(2,2,:),1,[])));
xscale('log'); title('Response Curve'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
legend('S_1_1', 'S_1_2', 'S_2_1', 'S_2_2');

option = 'db';

obj = @(x) synobj(x, sz, 1, option, f);
constr = @(x) synthconstr(x, sz);

switch option
    case 'db'
        err = db(reshape(f.ResponseData, 1, []));
    case 'phase'
    case 'dbphase'
    otherwise
        error('Invalid curve fitting option');
end

stx = rand(1, nvar);
lb = zeros(1, nvar);
ub = 1e2*ones(1, nvar);
% options = optimoptions("lsqcurvefit", "Display", "final", "PlotFcn", {'optimplotx', 'optimplotfval', 'optimplotfirstorderopt'}, "UseParallel", true);
% options.MaxFunctionEvaluations = 5e4;
% [result, res, fval, flag, output] = lsqcurvefit(obj, stx, freqs, err, lb, ub, [], [], [], [], constr, options);

goal = zeros(1, 4);
weight = 1e-3*ones(1, 4);

options = optimoptions("fgoalattain", "Display", "iter", "PlotFcn", {'optimplotx', 'optimplotfval'});
result = fgoalattain(obj, stx, goal, weight, [], [], [], [], lb, ub, constr, options);

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
function f = synobj(x, sz, freqs, option, comp)
    G = casctran(x, sz);
    H = tsc(G, sz);
    F = frd(H, freqs, 'FrequencyUnit', 'Hz');
    switch option
        case 'db'
            f = zeros(1, 4);
            for ii = 1:4
                [row, col] = ind2sub([2, 2], ii);
                k = reshape(db(F.ResponseData(row, col, :)), 1, []);
                g = reshape(db(comp.ResponseData(row, col, :)), 1, []);
                f(ii) = sqrt(mean((k-g).^2));
            end
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
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        c(ii) = getSectorIndex(H, Q) - (1 - eps^2); % Gain restraint
    end
end