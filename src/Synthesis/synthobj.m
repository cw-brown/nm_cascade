function f = synthobj(x, sz, freqs)
    networks = fpg(sz);
    s_param = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 13*(networks(ii)^2+networks(ii))/2;
        g = mimotm(x(st:st+nvar-1), networks(ii));
        s_param{ii} = freqresp(g, freqs);
    end
    s = l2casc(s_param, freqs, sz); s = s(1, 2, :);
    f = db(s(:)');
end