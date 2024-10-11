function g = stransfer(n, sz)
    %% Reciprocal transfer function matrix maker
    g = tf();
    ntran = (sz^2+sz)/2;
    [a, b] = meshgrid(1:sz, 1:sz);
    a = triu(a); b = triu(b);
    a = a(a ~= 0); b = b(b ~= 0);
    st = 1;
    for ii = 1:ntran
        poles = [-abs(n(st))+1j*n(st+1), -abs(n(st))-1j*n(st+1), ...
                 -abs(n(st+2))+1j*n(st+3), -abs(n(st+2))-1j*n(st+3), ...  
                 -abs(n(st+4))];
        zeros = [n(st+5), n(st+6), n(st+7)];
        gain = n(st+8);
        g(:, :, a(ii), b(ii)) = zpk(zeros, poles, gain);
        g(:, :, b(ii), a(ii)) = g(:, :, a(ii), b(ii));
        st = st + 9;
    end
end