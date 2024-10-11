%% Optimization Sheet
% 1. Make N networks that are 2x2 transfer functions
% 2. Series connect the systems
% 3. Turn to S matrix
close all; clear; clc;
freqs = logspace(3, 6, 150);
N = 2;
nvar = 13*N;

%%
stx = rand(1, nvar);

[z,p,k] = butter(3, 2e7, "s");
filt = zpk(z, p, k);
[err1, err2] = bode(filt, freqs);

obj = @(x)testopt(x, N, freqs, err1, err2);
% 
% goal = [0.0001, 0.0001];
% weight = abs(goal);
% options = optimoptions("fgoalattain", "PlotFcn", "optimplotfval", "UseParallel", true, "EqualityGoalCount", 2);
% result = fgoalattain(obj, stx, goal, weight, [], [], [], [], [], [], [], options);

result = fmincon(obj, stx);

%%
figure;
H = seriescon(result, N);
bode(H);
hold on;
grid on;
xscale("log");
bode(filt);
legend("Synthesis", "Target");

%% Functions
function g = maketransfer(n)
    poles = [-abs(n(1))+1j*n(2), -abs(n(1))-1j*n(2), ...
             -abs(n(3))+1j*n(4), -abs(n(3))-1j*n(4), ...
             -abs(n(5))+1j*n(6), -abs(n(5))-1j*n(6), ...
             -abs(n(7)), -abs(n(8))];
    zeros = [n(9), n(10), n(11), n(12)];
    gain = n(13);
    g = zpk(zeros, poles, gain);
end

function f = testopt(x, N, freqs, err1, err2)
    st = 1;
    seriessys = tf(1);
    for ii = 1:N
        H = maketransfer(x(st:st+11));
        st = st + 13;
        seriessys = series(seriessys, H);
    end
    [mag, phase] = bode(seriessys, freqs);
    mag = 20*log10(mag);
    err1 = 20*log10(err1);
    f(1) = sqrt(mean((mag(:)' - err1(:)').^2));
    % f(2) = sqrt(mean((phase(:)' - err2(:)').^2));
end

function s = seriescon(x, N)
    st = 1;
    s = tf(1);
    for ii = 1:N
        H = maketransfer(x(st:st+12));
        st = st + 13;
        s = series(s, H);
    end
end
