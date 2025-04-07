%% Arbitrary Network
close; clear testsheet; clc;
nfreqs = 200;
freqs = linspace(0,1,nfreqs);
magpart = linspace(0,1,nfreqs);
phasepart = cos(2*pi*freqs+deg2rad(-90));
s11 = magpart.*exp(1j*phasepart);
s22 = s11;
s12 = sqrt(1-magpart.^2).*exp(1j*(phasepart-pi/2));
s21 = s12;
s = zeros(2,2,nfreqs);
s(1,1,:) = s11;
s(1,2,:) = s12;
s(2,1,:) = s21;
s(2,2,:) = s22;
xlims = [0, 1];
ylims = [-70, 10];
sc = sparameters(s,freqs);
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

%%
c = circuit();
add(c, [1 2], capacitor(0.45));
add(c, [2 3], inductor(2.25));
add(c, [3 4], capacitor(1));
add(c, [2 3], resistor(0.1));
add(c, [2 5], inductor(0.5));
add(c, [3 5], capacitor(0.25));
add(c, [3 5], inductor(0.75));
add(c, [1 5], capacitor(0.01));
add(c, [1 4], inductor(0.95));
setports(c, [1 4], [3 5]);
freqs = linspace(0.1, 1, 200);
sc = sparameters(c, freqs);
sc.Parameters(1,2,:) = sc.Parameters(1,2,:)*1.3e1;
sc.Parameters(2,1,:) = sc.Parameters(2,1,:)*1.3e1;
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

%%
