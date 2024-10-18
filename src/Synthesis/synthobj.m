function f = synthobj(x, sz, freqs)
    networks = fpg(sz);
    g = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 7*(networks(ii)^2+networks(ii))/2;
        g{ii} = mimotm(x(st:st+nvar-1), networks(ii));
        st = st + nvar;
    end
    H = tsc(g, sz); H = freqresp(H(1, 2), freqs);
    f = db(H(:)');
end