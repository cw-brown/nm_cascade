function [c, ceq] = synthconstr(x, sz, freqs)
    G = casctran(x, sz);
    n = length(G);
    ports = fpg(sz);
    c = zeros(n + sum(ports), 1);
    for ii = 1:n
        g = G{ii};
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        c(ii) = getSectorIndex(H, Q); % Gain restraint
    end

    ceq = zeros(1, sum(ports));
    st = n+1;
    Q = [1, -0.95; -0.95, 0];
    for ii = 1:n
        for jj = 1:ports(ii)
            g = G{ii};
            S = g(jj, jj);
            Z = 50*(1+S)/(1-S);
            H = [Z; 1];
            c(st) = getSectorIndex(H, Q) - 1;
            st = st + 1;
        end
    end
end