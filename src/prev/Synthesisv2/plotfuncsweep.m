clear; clc; 

freqs = linspace(0, 6, 200);
nvar = 16;
stx = [0,1,1,6.67e-4,1,-1499,1499,1,1,-50,50,8329,0,50,50,8329];

sweep = linspace(-1e3, 1e3, 200);

% figure
% for ii = 13:16
%     subplot(2,2,ii-12);
%     x = stx;
%     for jj = 1:length(sweep)
%         x(ii) = sweep(jj);
%         y = mt(x, freqs);
%         plot(freqs, db(squeeze(y.Parameters(1,1,:))), LineWidth=0.5); hold on;
%     end
% end

% figure
% for ii = 1:16
%     subplot(4, 4, ii);
%     for jj = 1:length(sweep)
%         x = stx;
%         x(ii) = sweep(jj);
%         y = mt(x, freqs);
%         plot(freqs, db(squeeze(y.Parameters(1,1,:))), LineWidth=0.5); hold on;
%     end
%     xlabel('Frequency'); ylabel('Magnitude (dB)'); title('S_1_1');
% end


figure
for ii = 1:16
    subplot(4, 4, ii);
    for jj = 1:length(sweep)
        x = stx;
        x(ii) = sweep(jj);
        y = mt(x, freqs);
        plot(freqs, db(squeeze(y.Parameters(1,2,:))), LineWidth=0.5); hold on;
    end
    xlabel('Frequency'); ylabel('Magnitude (dB)'); title('S_1_2');
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