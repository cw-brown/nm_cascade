function [c, ceq] = synthconstr(x, sz, freqs)
    G = casctran(x, sz);
    n = length(G);
    c = zeros(1, n);
    for ii = 1:n
        g = G{ii};
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        c(ii) = getSectorIndex(H, Q); % Gain restraint
    end

    ports = fpg(sz);
    ceq = zeros(1, sum(ports));
    st = n+1;
    for ii = 1:n
        for jj = 1:ports(ii)
            g = G{ii};
            S = g(jj, jj);
            X = reshape(imag(freqresp(S, freqs)), 1, []);
            divX = gradient(X);
            c(st) = all(divX >= 0) - 1;
            st = st + 1;
        end
    end
end