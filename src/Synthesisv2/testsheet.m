s = tf('s');

H = 1.984e27*s^3/(s^6+2.513e9*s^5+1.216e20*s^4+2.004e29*s^3+4.8e39*s^2+3.917e48*s+6.153e58);
freqs = linspace(5e9, 8e9, 200);
f = freqresp(H, freqs);
plot(freqs, db(squeeze(f(1,1,:))));