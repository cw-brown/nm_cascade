R = @(x)obj(x);
A = [-1,0;...
    0,-1];
b = [eps,eps];

% solution = fgoalattain(R,100*rand(1,2),1000,1,A,b);
% w0 = 1/sqrt(solution(1)*solution(2));
% Q = 1/(w0*50*solution(1));

s = tf('s');
freqs = linspace(eps, 6, 200);

solution(1) = 6.67e-6;
solution(2) = 16658;
Z = 1/(s*solution(1));
g(1,1) = Z/(100+Z); g(2,2) = g(1,1);
g(1,2) = 100/(100+Z); g(2,1) = g(1,2);
s1 = sparameters(freqresp(g, freqs), freqs);

Z = s*solution(2);
h(1,1) = Z/(100+Z); h(2,2) = h(1,1);
h(1,2) = 100/(100+Z); h(2,1) = h(1,2);
s2 = sparameters(freqresp(h, freqs), freqs);

sc = cascadesparams(s1, s2);
figure;
plot(freqs, db(squeeze(sc.Parameters(1,1,:))), freqs, db(squeeze(sc.Parameters(1,2,:))), ...
    freqs, db(squeeze(sc.Parameters(2,1,:))), freqs, db(squeeze(sc.Parameters(2,2,:)))); grid on;
legend('db(S_1_1)', 'db(S_1_2)', 'db(S_2_1)', 'db(S_2_2)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Cascaded Network'); drawnow;


function f = obj(x)
    w0 = 1/sqrt(x(1)*x(2));
    f = 1/w0/50/x(1);
end