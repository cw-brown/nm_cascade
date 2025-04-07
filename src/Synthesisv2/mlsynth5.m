%% Setup for synthesis
% clear; clc; close all;
% rng(17450);
close all;

% nfreqs = 200;
% freqs = linspace(0.1,1,nfreqs);
% magpart = cos(2*pi*freqs);
% phasepart = cos(2*pi*freqs+deg2rad(-90));
% s11 = magpart.*exp(1j*phasepart);
% s22 = s11;
% s12 = sqrt(1-magpart.^2).*exp(1j*(phasepart-pi/2));
% s21 = s12;
% s = zeros(2,2,nfreqs);
% s(1,1,:) = s11;
% s(1,2,:) = s12;
% s(2,1,:) = s21;
% s(2,2,:) = s22;
% sc = sparameters(s,freqs);
% xlims = [min(freqs), 1];
% ylims = [-70, 10];

sc = sparameters('lowpass.s2p');
freqs = sc.Frequencies / max(sc.Frequencies);
xlims = [min(freqs), 1];
ylims = [-70, 10];

% c = circuit();
% add(c, [1 2], capacitor(7.45));
% add(c, [2 3], inductor(2.25));
% add(c, [3 4], capacitor(1));
% add(c, [2 3], resistor(0.1));
% add(c, [2 5], inductor(0.5));
% add(c, [3 5], capacitor(0.25));
% add(c, [3 5], inductor(0.75));
% add(c, [1 5], capacitor(1));
% add(c, [1 4], inductor(0.95));
% setports(c, [1 4], [3 5]);
% freqs = linspace(0.1, 1, 200);
% sc = sparameters(c, freqs);
% sc.Parameters(1,2,:) = sc.Parameters(1,2,:)*0.5e1;
% sc.Parameters(2,1,:) = sc.Parameters(2,1,:)*0.5e1;
% xlims = [min(freqs), 1];
% ylims = [-70, 10];

% T = readtable('bfp540_sopt.csv');
% freqs = T.freq;
% freqs = freqs / max(freqs);
% xlims = [min(freqs), 1];
% ylims = [-70, 5];

figure('Name','Cascaded Network'); subplot(2,2,1);
plot(freqs, real(squeeze(sc.Parameters(1,1,:))), freqs, real(squeeze(sc.Parameters(1,2,:))), ...
     freqs, real(squeeze(sc.Parameters(2,1,:))), freqs, real(squeeze(sc.Parameters(2,2,:)))); grid on;
title('Real Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); xlim(xlims);
subplot(2,2,2);
plot(freqs, imag(squeeze(sc.Parameters(1,1,:))), freqs, imag(squeeze(sc.Parameters(1,2,:))), ...
     freqs, imag(squeeze(sc.Parameters(2,1,:))), freqs, imag(squeeze(sc.Parameters(2,2,:)))); grid on;
title('Imaginary Component'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); xlim(xlims);
subplot(2,2,[3,4]);
plot(freqs, db(squeeze(sc.Parameters(1,1,:))), freqs, db(squeeze(sc.Parameters(1,2,:))), ...
     freqs, db(squeeze(sc.Parameters(2,1,:))), freqs, db(squeeze(sc.Parameters(2,2,:)))); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); xlim(xlims); ylim(ylims);
legend('S_1_1', 'S_1_2', 'S_2_1', 'S_2_2');
sgtitle('Desired Network'); drawnow;

%% Optimization
% err = [real(squeeze(sc.Parameters(1,1,:)))'...
%        real(squeeze(sc.Parameters(1,2,:)))'...
%        real(squeeze(sc.Parameters(2,2,:)))'...
%        imag(squeeze(sc.Parameters(1,1,:)))'...
%        imag(squeeze(sc.Parameters(1,2,:)))'...
%        imag(squeeze(sc.Parameters(2,2,:)))'];
err = [real(squeeze(sc.Parameters(1,2,:)))'...
       imag(squeeze(sc.Parameters(1,2,:)))'];

% Automatically find the best grid size that can match the target
eval = [2,16,20,28,40,44,52,64,68,76,88,92,100,112,116,124,136,140,148,160,...
    164,172,184,188,196]; % for first order systems
% eval = [4 28 40 56 76 88 104 124 136 152 172 184 200 220 232]; % second order
fit = rational(sc);
[m,n] = ind2sub([1,25],find(eval >= 8*fit.NumPoles,1));
sz = [m,n,1,m*n];
disp(['Automatic Grid Size: ' num2str(m) 'x' num2str(n)]);
networks = fpg(sz);
nvar = 3*sum(networks.^2+networks)/2;
   
obj = @(x)synthobj(x,sz,freqs,err);
constr = @(x)synconstr(x,sz);

ub = 10;
lb = -10;
x = (ub-lb)*rand(1, nvar)+lb;
ub = ub*ones(1, nvar);
lb = -ub;

%% fmincon optimization
options = optimoptions("fmincon","Display","iter","UseParallel",true,...
    "MaxFunctionEvaluations",2.5e5,"MaxIterations",3e9,...
    "PlotFcn",["optimplotx","optimplotfirstorderopt","optimplotfvalconstr"]);
tic
[solution,fval,flag,output] = fmincon(obj,x,[],[],[],[],lb,ub,[],options);
toc

%%
% options = optimoptions("lsqcurvefit","Display","iter","UseParallel",true,...
%     "MaxFunctionEvaluations",5e5,"PlotFcn","optimplotfval","MaxIterations",1e3,...
%     "SubproblemAlgorithm","cg");
% obj = @(x,xdata) synthobjcurve(x,sz,xdata);
% solution = lsqcurvefit(obj,x,freqs,err,lb,ub,[],[],[],[],[],options);
%% Plot output
G = tranmake(solution, sz);
H = tsc(G, sz);
Y = sparameters(freqresp(H,freqs),freqs);
% Y = best_optimal;

figure('Name','Real Results','NumberTitle','off');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, real(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, real(squeeze(Y.Parameters(row,col,:))));
    xlabel('Frequency (Hz)'); xlim(xlims);
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
    ylim([-1, 1]);
end
sgtitle('Real Results');
figure('Name','Imaginary Results','NumberTitle','off');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, imag(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, imag(squeeze(Y.Parameters(row,col,:))));
    xlabel('Frequency (Hz)'); xlim(xlims);
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
    ylim([-1, 1]);
end
sgtitle('Imaginary Results');
figure('Name','Conglomerate Results','NumberTitle','off');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    plot(freqs, db(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, db(squeeze(Y.Parameters(row,col,:))));
end
title('Synthesis vs Desired'); grid on; xlim(xlims); ylim(ylims);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
figure('Name','Comparison','NumberTitle','off');
for ii = 1:4
    [row, col] = ind2sub([2, 2], ii);
    subplot(2, 2, ii);
    plot(freqs, db(squeeze(sc.Parameters(row,col,:)))); hold on;
    plot(freqs, db(squeeze(Y.Parameters(row,col,:))));
    xlabel('Frequency (Hz)'); xlim(xlims); ylim(ylims);
    title(['S_' num2str(col) '_' num2str(row)]); grid on;
end
sgtitle('Comparison of Magnitudes');
% figure('Name','Grid Networks','NumberTitle','off');
% for ii = 1:m*n
%     subplot(n,m,ii);
%     F = sparameters(freqresp(G{ii},freqs),freqs);
%     rfplot(F); legend('off'); ylim(ylims); xlim(xlims);
%     title(['Network ' num2str(ii)]);
% end
% sgtitle('Grid Networks');

% for ii = 1:m*n
%     figure('Name',['Network ' num2str(ii)],'NumberTitle','off');
%     F = sparameters(freqresp(G{ii},freqs),freqs);
%     rfplot(F); title(['Network ' num2str(ii)]);
%     xlim(xlims); ylim(ylims);
% end

%% Functions
function gsys = tranmake(x, sz)
    % Return a cell array of MIMO systems formed from x values
    networks = fpg(sz);
    gsys = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 3*(networks(ii)^2+networks(ii))/2;
        gsys{ii} = mimotm(x(st:st+nvar-1), networks(ii));
        st = st + nvar;
    end

    function g = mimotm(x, sz)
        s = tf('s');
        nt = (sz^2 + sz)/2;
        g = tf(1, 1);
        i = meshgrid(1:sz, 1:sz);
        ip = triu(i); ig = triu(i');
        ip = nonzeros(ip); ig = nonzeros(ig);
        nf = 3;
        for jj = 1:nt
            g(ip(jj), ig(jj)) = x((jj-1)*nf+1) + ...
                x((jj-1)*nf+2)/(s+abs(x((jj-1)*nf+3)));
            g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
        end
    end
end

function f = synthobj(x, sz, freqs, err)
    G = tranmake(x, sz);
    H = tsc(G, sz);
    F = sparameters(freqresp(H,freqs),freqs);
    % U = [real(squeeze(F.Parameters(1,1,:)))'...
    %      real(squeeze(F.Parameters(1,2,:)))'...
    %      real(squeeze(F.Parameters(2,2,:)))'...
    %      imag(squeeze(F.Parameters(1,1,:)))'...
    %      imag(squeeze(F.Parameters(1,2,:)))'...
    %      imag(squeeze(F.Parameters(2,2,:)))'];
    U = [real(squeeze(F.Parameters(1,2,:)))'...
         imag(squeeze(F.Parameters(1,2,:)))'];
    f = rmse(U,err);
end

function f = synthobjcurve(x, sz, freqs)
    G = tranmake(x, sz);
    H = tsc(G, sz);
    F = sparameters(freqresp(H,freqs),freqs);
    % U = [real(squeeze(F.Parameters(1,1,:)))'...
    %      real(squeeze(F.Parameters(1,2,:)))'...
    %      real(squeeze(F.Parameters(2,2,:)))'...
    %      imag(squeeze(F.Parameters(1,1,:)))'...
    %      imag(squeeze(F.Parameters(1,2,:)))'...
    %      imag(squeeze(F.Parameters(2,2,:)))'];
    U = [real(squeeze(F.Parameters(1,2,:)))'...
         imag(squeeze(F.Parameters(1,2,:)))'];
    f = U;
end


function [c, ceq] = synconstr(x, sz)
    G = tranmake(x, sz);
    n = length(G);
    ceq = zeros(n, 1);
    c = zeros(n, 1);
    for ii = 1:n
        c(ii) = getPeakGain(G{ii}) - 1;
    end
end