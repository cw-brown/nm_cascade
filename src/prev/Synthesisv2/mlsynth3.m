%% Test set up
% H = mt([0,1,1,6.67e-4,1,-1499,1499,1,1,-50,50,8329,0,50,50,8329], freqs);

%% Circuit 1 in S-parameters
clear; clc; close all;
s = tf('s');
stx = [6.67e-6, 16658];
nfreq = 100;
freqs = linspace(0.1, 6, nfreq);
% Circuit 1 - capacitor
Z = 1/(s*stx(1));
g(1,1) = Z/(100+Z); g(2,2) = g(1,1);
g(1,2) = 100/(100+Z); g(2,1) = g(1,2);
s1 = sparameters(freqresp(g, freqs), freqs);
% figure
% plot(freqs, db(squeeze(s1.Parameters(1,1,:))), freqs, db(squeeze(s1.Parameters(1,2,:))), ...
%     freqs, db(squeeze(s1.Parameters(2,1,:))), freqs, db(squeeze(s1.Parameters(2,2,:)))); grid on;
% legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
% xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Circuit 1');

%% Circuit 2 in S-parameters
% Circuit 1 - inductor
Z = s*stx(2);
h(1,1) = Z/(100+Z); h(2,2) = h(1,1);
h(1,2) = 100/(100+Z); h(2,1) = h(1,2);
s2 = sparameters(freqresp(h, freqs), freqs);
% figure
% plot(freqs, db(squeeze(s2.Parameters(1,1,:))), freqs, db(squeeze(s2.Parameters(1,2,:))), ...
%     freqs, db(squeeze(s2.Parameters(2,1,:))), freqs, db(squeeze(s2.Parameters(2,2,:)))); grid on;
% legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
% xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Circuit 1');

%% Cascaded
sc = cascadesparams(s1, s2);
figure;
plot(freqs, db(squeeze(sc.Parameters(1,1,:))), freqs, db(squeeze(sc.Parameters(1,2,:))), ...
    freqs, db(squeeze(sc.Parameters(2,1,:))), freqs, db(squeeze(sc.Parameters(2,2,:)))); grid on;
legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Cascaded Network'); drawnow;

%% Optimization Setups
err = [real(squeeze(sc.Parameters(1,1,:)))'...
       real(squeeze(sc.Parameters(1,2,:)))'...
       imag(squeeze(sc.Parameters(1,1,:)))'...
       imag(squeeze(sc.Parameters(1,2,:)))'];

obj = @(x) mlobj(x, freqs, err);
constr = @(x) nonconstr(x);
nvar = 16;
x = 20*rand(1, nvar)-10;
% x = [0,1,1,6.67e-4,1,-1499,1499,1,1,-50,50,8329,0,50,50,8329];

ub = 10*ones(1, nvar);
lb = -ub;

%%
% options = optimoptions("fmincon","Display","iter","UseParallel",true);
% solution = fmincon(obj,x,[],[],[],[],[],[],constr,options);

% options = optimoptions("fmincon","Display","none","UseParallel",true,...
%     "MaxFunctionEvaluations",4e3);
% prob = createOptimProblem('fmincon', 'x0',x,'lb',[],'ub',[],'options',options, ...
%     'objective',obj,'Aineq',A,'bineq',b);
% gs = GlobalSearch('Display','iter','PlotFcn','gsplotbestf');
% solution = run(gs, prob);

% options = optimoptions("fminimax","Display","iter","UseParallel",true,"PlotFcn","optimplotfval");
% solution = fminimax(obj,x,[],[],[],[],[],[],[],options);

curve_obj = @(x, xdata) mlobj_curve(x, xdata);
options = optimoptions("lsqcurvefit","Display","iter","UseParallel",true);
solution = lsqcurvefit(curve_obj,x,freqs,err,[],[],[],[],[],[],constr,options);

%% Results
Y = mt(solution, freqs);
figure
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, reshape(db(sc.Parameters(row, col, :)), 1, []), freqs, reshape(db(Y.Parameters(row, col, :)), 1, []));
    xscale('linear'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    % legend('Input', 'Synthesis');
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
end
figure;
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, ((angle(squeeze(sc.Parameters(row, col, :))))), freqs, ((angle(squeeze(Y.Parameters(row, col, :))))));
    xscale('linear'); xlabel('Frequency (Hz)'); ylabel('Phase (radians)');
    % legend('Input', 'Synthesis');
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
end
figure
K = errcalc(solution, freqs, err);
subplot(2,2,1);
plot(freqs, K(1:nfreq));
subplot(2,2,2);
plot(freqs, K((nfreq+1):(2*nfreq)));
subplot(2,2,3);
plot(freqs, K((2*nfreq+1):(3*nfreq)));
subplot(2,2,4);
plot(freqs, K((3*nfreq+1):(4*nfreq)));

%%
function f = mlobj(x, freqs, err)
    Y = mt(x, freqs);
    U = [real(squeeze(Y.Parameters(1,1,:)))'...
         real(squeeze(Y.Parameters(1,2,:)))'...
         imag(squeeze(Y.Parameters(1,1,:)))'...
         imag(squeeze(Y.Parameters(1,2,:)))'];
    f = rmse(U,err);
end

function y = mt(x, freqs)
    s = tf('s');
    g(1,1) = x(1) + x(2)/(abs(x(3))+s*x(4)); g(2,2) = g(1,1);
    g(1,2) = x(5) + x(6)/(abs(x(7))+s*x(8)); g(2,1) = g(1,2);
    F1 = sparameters(freqresp(g, freqs), freqs);

    h(1,1) = x(9) + x(10)/(abs(x(11))+s*x(12)); h(2,2) = h(1,1);
    h(1,2) = x(13) + x(14)/(abs(x(15))+s*x(16)); h(2,1) = h(1,2);
    F2 = sparameters(freqresp(h, freqs), freqs);
    y = cascadesparams(F1, F2);
end

function f = errcalc(x, freqs, err)
    Y = mt(x, freqs);
    U = [real(squeeze(Y.Parameters(1,1,:)))'...
         real(squeeze(Y.Parameters(1,2,:)))'...
         imag(squeeze(Y.Parameters(1,1,:)))'...
         imag(squeeze(Y.Parameters(1,2,:)))'];
    f = U-err;
end

function f = mlobj_curve(x, freqs)
    Y = mt(x, freqs);
    f = [real(squeeze(Y.Parameters(1,1,:)))'...
         real(squeeze(Y.Parameters(1,2,:)))'...
         imag(squeeze(Y.Parameters(1,1,:)))'...
         imag(squeeze(Y.Parameters(1,2,:)))'];
end

function [c,ceq] = nonconstr(x)
    s = tf('s');
    g(1,1) = x(1) + x(2)/(abs(x(3))+s*x(4)); g(2,2) = g(1,1);
    g(1,2) = x(5) + x(6)/(abs(x(7))+s*x(8)); g(2,1) = g(1,2);

    h(1,1) = x(9) + x(10)/(abs(x(11))+s*x(12)); h(2,2) = h(1,1);
    h(1,2) = x(13) + x(14)/(abs(x(15))+s*x(16)); h(2,1) = h(1,2);
    c(1) = getPeakGain(g) - 1;
    c(2) = getPeakGain(h) - 1;
    ceq = [];
end