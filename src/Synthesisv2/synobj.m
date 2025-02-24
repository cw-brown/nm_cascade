function f = synobj(x, sz, freqs)
    G = casctran(x, sz);
    H = tsc(G, sz);
    F = freqresp(H, freqs);
    f = [squeeze(abs(F(1,1,:))), ...
         squeeze(abs(F(1,2,:))), ...
         squeeze(abs(F(2,2,:)))];
end