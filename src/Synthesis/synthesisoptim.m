function f = synthesisoptim(x, sz, freqs, err)
    ports = fpg(sz); ports = ports(2:end-1);
    s_params = cell(1, length(ports));
    st = 1;
    for ii = 1:length(ports)
        N = ports(ii);
        nvar = 11 * (N^2+N)/2;
        H = reciprocalN(x(st:st+nvar-1), N);
        st = st + nvar;
        s_params{ii} = freqresp(H, freqs);
    end
    s = l2casc(s_params, freqs, sz); s = s(1, 2, :);
    f(1) = sqrt(mean((db(err(:)') - db(s(:)')).^2));
    f(2) = sqrt(mean((angle(err(:)') - angle(s(:)')).^2));
end