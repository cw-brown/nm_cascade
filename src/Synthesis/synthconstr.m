function [c, ceq] = synthconstr(x, sz)
    G = casctran(x, sz);
    n = length(G);
    ceq = [];
    c = zeros(n, 1);
    for ii = 1:n
        g = G{ii};
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        c(ii) = getSectorIndex(H, Q) - (1 - eps^2); % Gain restraint
    end
end