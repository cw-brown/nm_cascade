clear; close all;
% G = zpk([-0.2+0.1j, -0.2-0.1j], [-0.6+2j, -0.6-2j, -0.6], 0.85);
% G(1,1) = tf([1 1], [1 2]);
% G(2,2) = tf([1 1], [1 2]);
% G(1,2) = tf([0.05, 0.3, 1], [4, 3, 1]);
% G(2,1) = G(1,2);

G = tf(1);

[nu, ~] = iosize(G);
% isPassive(G)
H = ss(G);
figure
bode(G);
figure
nyquist(G)
freqs = logspace(0, 9, 200);

%% Passivity Constraint on G, pidx<1
Q = [zeros(nu) -eye(nu); -eye(nu) zeros(nu)];
[W1, W2] = getQData(Q);
pidx = norm((W1'*[G;eye(nu)])/(W2'*[G;eye(nu)]), Inf);

%% Gain Constraint on G, ||G||<1
Q = [eye(nu), zeros(nu); zeros(nu), -eye(nu)];
[W1, W2] = getQData(Q);
gidx = norm((W1'*[G;eye(nu)])/(W2'*[G;eye(nu)]), Inf);

%% Conversion to Z-Parameters
rtz = sqrt(50)*eye(nu);
% Z = rtz*(eye(nu)+G)/(eye(nu)-G)*rtz;
s = tf('s');
Z = 1e-4*s + 1/(s*2.5e-6); % inductor and capacitor
F = frd(Z, freqs);
figure
ref = reshape(1:nu^2, nu, nu);
m = zeros(1, nu^2);
for ii = 1:nu
for jj = 1:nu
    subplot(nu, nu, ref(ii, jj));
    D = F.ResponseData(ii, jj, :);
    plot(freqs, imag(D(:)));
    xscale("log");
    title(['Reactance of Z_' num2str(jj) '_' num2str(ii)]);
    xlabel("Frequency (Hz)");
    ylabel("Reactance (Ohms)");
    m(ref(ii, jj)) = all(diff(imag(D)) >= 0);
end
end
Q = [zeros(nu) -eye(nu); -eye(nu) zeros(nu)];
[W1, W2] = getQData(Q);
zidx = norm((W1'*[Z;eye(nu)])/(W2'*[Z;eye(nu)]), Inf);


dets = zeros(1, length(freqs));
for ff = 1:length(freqs)
    dets(ii) = det(F.ResponseData(:,:,ff));
end
figure
plot(freqs, imag(dets));