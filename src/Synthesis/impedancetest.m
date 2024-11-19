%% Make the circuit
clear; close all;
freqs = logspace(1, 4.5, 500);

ck = circuit();

R = 100;
C = 1e-7;
L = 1e-5;

add(ck, [1 2], capacitor(C));
add(ck, [2 3], resistor(R));
add(ck, [3 4], capacitor(C));
add(ck, [2 3], resistor(R));
add(ck, [1 3], inductor(L));

setports(ck, [1 3], [3 4]);

%% S-Parameters
S = sparameters(ck, freqs);
figure(1);
rfplot(S);
xscale("log");

%% Z-Parameters and reactance
z = s2z(S.Parameters);
figure(2);

subplot(2, 2, 1);
U = z(1, 1, :);
plot(freqs, imag(U(:)));
xscale("log");
title("X_1_1 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

subplot(2, 2, 2);
U = z(1, 2, :);
plot(freqs, imag(U(:)));
xscale("log");
title("X_1_2 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

subplot(2, 2, 3);
U = z(2, 1, :);
plot(freqs, imag(U(:)));
xscale("log");
title("X_2_1 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

subplot(2, 2, 4);
U = z(2, 2, :);
plot(freqs, imag(U(:)));
xscale("log");
title("X_2_2 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

%% Derivative of Impedance
figure(3);

subplot(2, 2, 1);
U = z(1, 1, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{11}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

subplot(2, 2, 2);
U = z(1, 2, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{12}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

subplot(2, 2, 3);
U = z(2, 1, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{21}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

subplot(2, 2, 4);
U = z(2, 2, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{22}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

%% Susceptance Matrix
y = s2y(S.Parameters);
figure(4);

subplot(2, 2, 1);
U = y(1, 1, :);
plot(freqs, imag(U(:)));
xscale("log");
title("B_1_1 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

subplot(2, 2, 2);
U = y(1, 2, :);
plot(freqs, imag(U(:)));
xscale("log");
title("B_1_2 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

subplot(2, 2, 3);
U = y(2, 1, :);
plot(freqs, imag(U(:)));
xscale("log");
title("B_2_1 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

subplot(2, 2, 4);
U = y(2, 2, :);
plot(freqs, imag(U(:)));
xscale("log");
title("B_2_2 over Frequency");
xlabel("Frequency (Hz)");
ylabel("Reactance (Ohms)");

%% Derivative of 
figure(5);

subplot(2, 2, 1);
U = y(1, 1, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{11}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

subplot(2, 2, 2);
U = y(1, 2, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{12}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

subplot(2, 2, 3);
U = y(2, 1, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{21}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");

subplot(2, 2, 4);
U = y(2, 2, :);
plot(freqs, gradient(imag(U(:))));
xscale("log");
title('$\frac {\partial X_{22}}{\partial \omega}$', "Interpreter", "latex");
xlabel("Frequency (Hz)");
ylabel("Derivative Value");