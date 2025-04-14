function f = synthesizeobjcurve(x, sz, freqs)
    G = casctran(x, sz);
    H = tsc(G, sz);
    F = sparameters(freqresp(H,freqs),freqs);
    f = [real(squeeze(F.Parameters(1,1,:)))'...
         real(squeeze(F.Parameters(1,2,:)))'...
         real(squeeze(F.Parameters(2,2,:)))'...
         imag(squeeze(F.Parameters(1,1,:)))'...
         imag(squeeze(F.Parameters(1,2,:)))'...
         imag(squeeze(F.Parameters(2,2,:)))'];
end