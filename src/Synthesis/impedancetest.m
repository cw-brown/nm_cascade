%% Make the circuit
clear; close all;
freqs = logspace(1, 8, 5000);

ck = circuit();

add(ck, [1 2], capacitor(1e-5));
add(ck, [2 3], capacitor(1e-6));
add(ck, [2 4], capacitor(1e-3));
add(ck, [1 3], capacitor(50e-3));
add(ck, [1 3], inductor(1e-5));
add(ck, [1 2], inductor(1e-3));
add(ck, [1 5], inductor(1e-4));

setports(ck, [1 3], [3 4]);

%% S-Parameters
s = sparameters(ck, freqs);
figure(1);
rfplot(s);
xscale("log");

%% Z-Parameters and reactance
z = s2z(s.Parameters);
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
