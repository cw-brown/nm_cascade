clear; clc; close all;
G = zpk([-0.2+.1j, -0.2-.1j], [-.6+2j, -.6-2j, -0.6], 0.85);
isPassive(G)
H = ss(G);
figure
bode(G)
figure
nyquist(G)

freqs = logspace(0, 9, 200);

%% Passivity Constraint on G, pidx<1
Q = [0 -1; -1 0];
[W1, W2] = getQData(Q);
pidx = norm((W1'*[G;1])/(W2'*[G;1]), Inf);

%% Gain Constraint on G, ||G||<1
Q = [1, 0; 0, -1];
[W1, W2] = getQData(Q);
gidx = norm((W1'*[G;1])/(W2'*[G;1]), Inf);

%% S-parameter of G
F = frd(G, freqs);
J = sparameters(F.ResponseData, freqs);