function [c, ceq] = synthconstr(x, sz, freqs)
    G = casctran(x, sz);
    n = length(G);
    ceq = zeros(n, 1);
    c = zeros(n+2*n, 1);
    st = 1;
    for ii = 1:n
        g = G{ii};
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        c(st) = getSectorIndex(H, Q) - (1 - eps^2); % Gain restraint

        f = freqresp(g, freqs);
        c(st+1:st+length(g)) = sum(sum(abs(f.^2), 3), 1) - length(freqs);
        st = st+length(g)+1;
    end
end