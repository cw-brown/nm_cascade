function f = synthobj(x, sz, freqs)
    g = casctran(x, sz);
    H = tsc(g, sz); H = freqresp(H(1, 1), freqs);
    f = db(H(:)');
end