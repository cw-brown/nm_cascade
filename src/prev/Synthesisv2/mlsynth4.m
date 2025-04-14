%% Circuit test 2
clear; clc; close all;
s = tf('s');
nfreq = 200;
lims = [0.01,2];
freqs = linspace(lims(1), lims(2), nfreq);
stx = [1, 0.5, 0.35, 0.025, 0.025, 0.025];

%% Circuit 1
s1 = makecircuit(stx(1:3), freqs);
% figure('Name','Circuit 1'); subplot(2,2,1);
% plot(freqs, real(squeeze(s1.Parameters(1,1,:))), freqs, real(squeeze(s1.Parameters(1,2,:))), ...
%      freqs, real(squeeze(s1.Parameters(2,1,:))), freqs, real(squeeze(s1.Parameters(2,2,:)))); grid on;
% title('Circuit 1 Real Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
% subplot(2,2,2);
% plot(freqs, imag(squeeze(s1.Parameters(1,1,:))), freqs, imag(squeeze(s1.Parameters(1,2,:))), ...
%      freqs, imag(squeeze(s1.Parameters(2,1,:))), freqs, imag(squeeze(s1.Parameters(2,2,:)))); grid on;
% title('Circuit 1 Imaginary Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
% subplot(2,2,[3,4]);
% plot(freqs, db(squeeze(s1.Parameters(1,1,:))), freqs, db(squeeze(s1.Parameters(1,2,:))), ...
%      freqs, db(squeeze(s1.Parameters(2,1,:))), freqs, db(squeeze(s1.Parameters(2,2,:)))); grid on;
% title('Circuit 1'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
% legend('S_1_1', 'S_1_2', 'S_2_1', 'S_2_2');

%% Circuit 2
s2 = makecircuit(stx(3:6), freqs);
% figure('Name','Circuit 2'); subplot(2,2,1);
% plot(freqs, real(squeeze(s2.Parameters(1,1,:))), freqs, real(squeeze(s2.Parameters(1,2,:))), ...
%      freqs, real(squeeze(s2.Parameters(2,1,:))), freqs, real(squeeze(s2.Parameters(2,2,:)))); grid on;
% title('Circuit 2 Real Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
% subplot(2,2,2);
% plot(freqs, imag(squeeze(s2.Parameters(1,1,:))), freqs, imag(squeeze(s2.Parameters(1,2,:))), ...
%      freqs, imag(squeeze(s2.Parameters(2,1,:))), freqs, imag(squeeze(s2.Parameters(2,2,:)))); grid on;
% title('Circuit 2 Imaginary Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
% subplot(2,2,[3,4]);
% plot(freqs, db(squeeze(s2.Parameters(1,1,:))), freqs, db(squeeze(s2.Parameters(1,2,:))), ...
%      freqs, db(squeeze(s2.Parameters(2,1,:))), freqs, db(squeeze(s2.Parameters(2,2,:)))); grid on;
% title('Circuit 2'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
% legend('S_1_1', 'S_1_2', 'S_2_1', 'S_2_2');

%% Cascaded Network
sc = cascadesparams(s1, s2);
% filt = rss(7, 2, 2);
% e = getPeakGain(filt);
% while e > 1
%     filt = rss(7, 2, 2);
%     e = getPeakGain(filt);
% end
% filt(1, 2) = filt(2, 1);
% sc = sparameters(freqresp(filt,freqs),freqs);

figure('Name','Cascaded Network'); subplot(2,2,1);
plot(freqs, real(squeeze(sc.Parameters(1,1,:))), freqs, real(squeeze(sc.Parameters(1,2,:))), ...
     freqs, real(squeeze(sc.Parameters(2,1,:))), freqs, real(squeeze(sc.Parameters(2,2,:)))); grid on;
title('Real Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); xlim(lims);
subplot(2,2,2);
plot(freqs, imag(squeeze(sc.Parameters(1,1,:))), freqs, imag(squeeze(sc.Parameters(1,2,:))), ...
     freqs, imag(squeeze(sc.Parameters(2,1,:))), freqs, imag(squeeze(sc.Parameters(2,2,:)))); grid on;
title('Imaginary Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); xlim(lims);
subplot(2,2,[3,4]);
plot(freqs, db(squeeze(sc.Parameters(1,1,:))), freqs, db(squeeze(sc.Parameters(1,2,:))), ...
     freqs, db(squeeze(sc.Parameters(2,1,:))), freqs, db(squeeze(sc.Parameters(2,2,:)))); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); xlim(lims);
legend('S_1_1', 'S_1_2', 'S_2_1', 'S_2_2');
sgtitle('Desired Network'); drawnow;

%% Optimization Setups
err = [real(squeeze(sc.Parameters(1,1,:)))'...
       real(squeeze(sc.Parameters(1,2,:)))'...
       real(squeeze(sc.Parameters(2,2,:)))'...
       imag(squeeze(sc.Parameters(1,1,:)))'...
       imag(squeeze(sc.Parameters(1,2,:)))'...
       imag(squeeze(sc.Parameters(2,2,:)))'];

obj = @(x) mlobj(x, freqs, err);
constr = @(x) nonconstr(x);
nvar = 30;
x = 2*rand(1, nvar)-1;

ub = 1*ones(1, nvar);
lb = -ub;

%% Optimization
options = optimoptions("fmincon","Display","iter","UseParallel",true);
tic
solution = fmincon(obj,x,[],[],[],[],lb,ub,constr,options);
toc

% options = optimoptions("fmincon","Display","none","UseParallel",true,...
%     "MaxFunctionEvaluations",4e3);
% prob = createOptimProblem('fmincon', 'x0',x,'lb',lb,'ub',ub,'options',options, ...
%     'objective',obj,'nonlcon',[]);
% gs = GlobalSearch('Display','iter','PlotFcn','gsplotbestf');
% solution = run(gs, prob);

% options = optimoptions("fminimax","Display","iter","UseParallel",true,"PlotFcn","optimplotfval");
% solution = fminimax(obj,x,[],[],[],[],[],[],[],options);
% 
% curve_obj = @(x, xdata) mlobj_curve(x, xdata);
% options = optimoptions("lsqcurvefit","Display","iter","UseParallel",true);
% solution = lsqcurvefit(curve_obj,x,freqs,err,[],[],[],[],[],[],constr,options);

% options = optimoptions("patternsearch","Display","iter","UseParallel",true, ...
%     "MaxIterations",500,"PlotFcn",["psplotbestf","psplotmaxconstr"]);
% solution = patternsearch(obj,x,[],[],[],[],lb,ub,constr,options);

%% Results
Y = mt(solution, freqs);
% figure('Name','Magnitude Results');
% for ii = 1:4
%     [row, col] = ind2sub([2, 2], ii);
%     subplot(2, 2, ii);
%     plot(freqs, db(squeeze(sc.Parameters(row,col,:)))); hold on;
%     plot(freqs, db(squeeze(Y.Parameters(row,col,:))));
%     xlabel('Frequency (Hz)'); xlim(lims);
%     title(['S_' num2str(col) '_' num2str(row)]); grid on;
% end
% sgtitle('Magnitude (dB)');
% figure('Name','Angle Results');
% for ii = 1:4
%     [row, col] = ind2sub([2, 2], ii);
%     subplot(2, 2, ii);
%     plot(freqs, angle(squeeze(sc.Parameters(row,col,:)))); hold on;
%     plot(freqs, angle(squeeze(Y.Parameters(row,col,:))));
%     xlabel('Frequency (Hz)'); xlim(lims);
%     title(['S_' num2str(col) '_' num2str(row)]); grid on;
% end
% sgtitle('Angle (Radians)')
figure('Name','Real Results');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, real(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, real(squeeze(Y.Parameters(row,col,:))));
    xlabel('Frequency (Hz)'); xlim(lims);
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
    ylim([-1, 1]);
end
sgtitle('Real Results');
figure('Name','Imaginary Results');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, imag(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, imag(squeeze(Y.Parameters(row,col,:))));
    xlabel('Frequency (Hz)'); xlim(lims);
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
    ylim([-1, 1]);
end
sgtitle('Imaginary Results');
figure('Name','Total Error');
K = errcalc(solution, freqs, err);
subplot(2,2,1);
plot(freqs, K(1:nfreq));
subplot(2,2,2);
plot(freqs, K((nfreq+1):(2*nfreq)));
subplot(2,2,3);
plot(freqs, K((2*nfreq+1):(3*nfreq)));
subplot(2,2,4);
plot(freqs, K((3*nfreq+1):(4*nfreq)));
figure('Name','Conglomerate Results');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    plot(freqs, db(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, db(squeeze(Y.Parameters(row,col,:))));
end
title('Synthesis vs Desired'); grid on; xlim(lims);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');

%%
function f = mlobj(x, freqs, err)
    Y = mt(x, freqs);
    U = [real(squeeze(Y.Parameters(1,1,:)))'...
         real(squeeze(Y.Parameters(1,2,:)))'...
         real(squeeze(Y.Parameters(2,2,:)))'...
         imag(squeeze(Y.Parameters(1,1,:)))'...
         imag(squeeze(Y.Parameters(1,2,:)))'...
         imag(squeeze(Y.Parameters(2,2,:)))'];
    f = rmse(U,err);
end

function y = mt(x, freqs)
    s = tf('s');
    g(1,1) = x(1) + x(2)/(abs(x(3))+s) + x(4)/(abs(x(5))+s);
    g(1,2) = x(6) + x(7)/(abs(x(8))+s) + x(9)/(abs(x(10))+s);
    g(2,2) = x(11) + x(12)/(abs(x(13))+s) + x(14)/(abs(x(15))+s);
    g(2,1) = g(1,2);
    F1 = sparameters(freqresp(g, freqs), freqs);

    h(1,1) = x(16) + x(17)/(abs(x(18))+s) + x(19)/(abs(x(20))+s);
    h(1,2) = x(21) + x(22)/(abs(x(23))+s) + x(24)/(abs(x(25))+s);
    h(2,2) = x(26) + x(27)/(abs(x(28))+s) + x(29)/(abs(x(30))+s);
    h(2,1) = h(1,2);
    F2 = sparameters(freqresp(h, freqs), freqs);
    y = cascadesparams(F1, F2);
end

function y = mt_alt(x, freqs)
    s = tf('s');
    g(1,1) = x(1) + x(2)/(abs(x(3))+s) + x(4)/(abs(x(5))+s);
    g(1,2) = x(6) + x(7)/(abs(x(8))+s) + x(9)/(abs(x(10))+s);
    g(2,2) = x(11) + x(12)/(abs(x(13))+s) + x(14)/(abs(x(15))+s);
    g(2,1) = g(1,2);
    F1 = sparameters(freqresp(g, freqs), freqs);

    h(1,1) = x(16) + x(17)/(abs(x(18))+s) + x(19)/(abs(x(20))+s);
    h(1,2) = x(21) + x(22)/(abs(x(23))+s) + x(24)/(abs(x(25))+s);
    h(2,2) = x(26) + x(27)/(abs(x(28))+s) + x(29)/(abs(x(30))+s);
    h(2,1) = h(1,2);
    F2 = sparameters(freqresp(h, freqs), freqs);
    y{1} = g;
    y{2} = h;
end

function f = errcalc(x, freqs, err)
    Y = mt(x, freqs);
    U = [real(squeeze(Y.Parameters(1,1,:)))'...
         real(squeeze(Y.Parameters(1,2,:)))'...
         real(squeeze(Y.Parameters(2,2,:)))'...
         imag(squeeze(Y.Parameters(1,1,:)))'...
         imag(squeeze(Y.Parameters(1,2,:)))'...
         imag(squeeze(Y.Parameters(2,2,:)))'];
    f = U-err;
end

function f = mlobj_curve(x, freqs)
    Y = mt(x, freqs);
    f = [real(squeeze(Y.Parameters(1,1,:)))'...
         real(squeeze(Y.Parameters(1,2,:)))'...
         real(squeeze(Y.Parameters(2,2,:)))'...
         imag(squeeze(Y.Parameters(1,1,:)))'...
         imag(squeeze(Y.Parameters(1,2,:)))'...
         imag(squeeze(Y.Parameters(2,2,:)))'];
end

function [c,ceq] = nonconstr(x)
    s = tf('s');
    g(1,1) = x(1) + x(2)/(abs(x(3))+s) + x(4)/(abs(x(5))+s);
    g(1,2) = x(6) + x(7)/(abs(x(8))+s) + x(9)/(abs(x(10))+s);
    g(2,2) = x(11) + x(12)/(abs(x(13))+s) + x(14)/(abs(x(15))+s);
    g(2,1) = g(1,2);

    h(1,1) = x(16) + x(17)/(abs(x(18))+s) + x(19)/(abs(x(20))+s);
    h(1,2) = x(21) + x(22)/(abs(x(23))+s) + x(24)/(abs(x(25))+s);
    h(2,2) = x(26) + x(27)/(abs(x(28))+s) + x(29)/(abs(x(30))+s);
    h(2,1) = h(1,2);
    c(1) = getPeakGain(g) - 1;
    c(2) = getPeakGain(h) - 1;
    ceq = [];
end

function s = makecircuit(x, freqs)
    s = tf('s');
    Z1 = x(1)*s;
    Z2 = 1/(x(2)*s);
    Z3 = 1/(x(3)*s);
    A = 1+Z1/Z3;
    B = Z1+Z2+Z1*Z2/Z3;
    C = 1/Z3;
    D = 1+Z2/Z3;
    O = [freqresp(A,freqs), freqresp(B,freqs); freqresp(C,freqs), freqresp(D,freqs)];
    s = sparameters(abcd2s(O, 50),freqs);
end
