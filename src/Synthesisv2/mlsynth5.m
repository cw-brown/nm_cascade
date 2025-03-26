%% Setup for synthesis
clear; clc; close all;
rng(123456);

sc = sparameters('bandreject.s2p');
nfreqs = length(sc.Frequencies);
freqs = linspace(0,1,length(sc.Frequencies));
sc.Frequencies = freqs;
xlims = [0, 1];
ylims = [-60, 10];

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
err = [real(squeeze(sc.Parameters(1,1,:)))'...
       real(squeeze(sc.Parameters(1,2,:)))'...
       real(squeeze(sc.Parameters(2,2,:)))'...
       imag(squeeze(sc.Parameters(1,1,:)))'...
       imag(squeeze(sc.Parameters(1,2,:)))'...
       imag(squeeze(sc.Parameters(2,2,:)))'];

% Automatically find the best grid size that can match the target
eval = [2,16,20,28,40,44,52;...
        16,36,64,84,112,132,160;...
        20,64,100,140,184,220,260;...
        28,84,140,196,252,308,364];
fit = rational(sc);
[m,n] = ind2sub([4,7],find(eval >= 2*fit.NumPoles,1));
sz = [m,n,1,m*n];
disp(['Automatic Grid Size: ' num2str(m) 'x' num2str(n)]);

networks = fpg(sz);
nvar = 3*sum(networks.^2+networks)/2;
   
obj = @(x)synthobj(x,sz,freqs,err);
constr = @(x)synconstr(x,sz);

ub = 1;
lb = -1;
x = (ub-lb)*rand(1, nvar)+lb;
ub = ub*ones(1, nvar);
lb = -ub;

%% fmincon optimization
% options = optimoptions("fmincon","Display","iter","UseParallel",true,...
%     "MaxFunctionEvaluations",Inf,"MaxIterations",Inf,...
%     "PlotFcn",["optimplotx","optimplotfirstorderopt","optimplotfvalconstr"],...
%     "OptimalityTolerance",1e-6);
% tic
% [result,fval,flag,output] = fmincon(obj,x,[],[],[],[],lb,ub,constr,options);
% toc
% if flag >= 0
%     solution = result;
% elseif ~isempty(output) && flag < 0
%     solution = output.bestfeasible.x;
% end

%% lsqnonlin optimization
options = optimoptions("lsqcurvefit","Display","iter","UseParallel",true,...
    "MaxFunctionEvaluations",Inf,"MaxIterations",Inf,"PlotFcn",["optimplotx","optimplotfirstorderopt","optimplotfval"],...
    "OptimalityTolerance",1e-6);
objcurve = @(x,xdata)synthobjcurve(x,sz,xdata);
tic
[result,resnorm,res,flag,output] = lsqcurvefit(objcurve,x,freqs,err,lb,ub,[],[],[],[],constr,options);
solution = result;
%% Plot output
G = tranmake(solution, sz);
H = tsc(G, sz);
Y = sparameters(freqresp(H,freqs),freqs);

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
    U = [real(squeeze(F.Parameters(1,1,:)))'...
         real(squeeze(F.Parameters(1,2,:)))'...
         real(squeeze(F.Parameters(2,2,:)))'...
         imag(squeeze(F.Parameters(1,1,:)))'...
         imag(squeeze(F.Parameters(1,2,:)))'...
         imag(squeeze(F.Parameters(2,2,:)))'];
    f = rmse(U,err);
end

function f = synthobjcurve(x, sz, freqs)
    G = tranmake(x, sz);
    H = tsc(G, sz);
    F = sparameters(freqresp(H,freqs),freqs);
    U = [real(squeeze(F.Parameters(1,1,:)))'...
         real(squeeze(F.Parameters(1,2,:)))'...
         real(squeeze(F.Parameters(2,2,:)))'...
         imag(squeeze(F.Parameters(1,1,:)))'...
         imag(squeeze(F.Parameters(1,2,:)))'...
         imag(squeeze(F.Parameters(2,2,:)))'];
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