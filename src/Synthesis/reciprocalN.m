function H = reciprocalN(v, N)
    %% Creates a MIMO reciprocal NxN transfer network
    H = tf();
    ntran = (N^2+N)/2;
    [a, b] = meshgrid(1:N, 1:N);
    a = triu(a); b = triu(b);
    a = a(a ~= 0); b = b(b ~= 0);
    st = 1;
    for ii = 1:ntran
        gain = v(st);
        zeros = [v(st+1), v(st+2), v(st+3)];
        poles = [-abs(v(st+4))+1j*v(st+5), -abs(v(st+4))-1j*v(st+5), ...
                 -abs(v(st+6))+1j*v(st+7), -abs(v(st+6))-1j*v(st+7), ...
                 -abs(v(st+8))+1j*v(st+9), -abs(v(st+8))-1j*v(st+9), ...
                 -abs(v(st+10))];
        st = st + 11;
        H(a(ii), b(ii)) = zpk(zeros, poles, gain);
        H(b(ii), a(ii)) = H(a(ii), b(ii));
    end
end