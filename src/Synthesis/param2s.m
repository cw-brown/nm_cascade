function s = param2s(n, sz, freqs, terms)
    persistent stf;
    stf = tf('s');
    ntran = (sz^2+sz)/2;
    [a, b] = meshgrid(1:sz, 1:sz);
    a = triu(a); b = triu(b);
    a = a(a ~= 0); b = b(b ~= 0);
    st = 1;
    g = tf(zeros(sz, sz));
    for ii = 1:ntran
        tran = 0;
        for tt = 1:terms
            tran = tran + (n(st)+1j*n(st+1))/(stf+n(st+2)+1j*n(st+3));
            st = st+4;
        end
        g(a(ii), b(ii)) = tran;
        g(b(ii), a(ii)) = g(a(ii), b(ii));
    end
    s = freqresp(g, freqs);
end