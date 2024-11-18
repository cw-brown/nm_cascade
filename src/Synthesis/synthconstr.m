function [c, ceq] = synthconstr(x, sz, freqs)
    G = casctran(x, sz);
    n = length(G);
    c = zeros(1, n);
    ceq = [];
    for ii = 1:n
        g = G{ii};
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        Q = [eye(nu), zeros(nu); zeros(ny), -eye(ny)];
        c(ii) = getSectorIndex(H, Q); % Gain restraint
    end
    H = tsc(G, sz);
    Z = sqrt(50)*eye(2)*(eye(2)+H)/(eye(2)-H)*sqrt(50)*eye(2);
    F = freqresp(Z, freqs);
    % c = [c, -gradient(imag(reshape(F(1, 1, :), 1, [])), freqs(2)-freqs(1)), -gradient(imag(reshape(F(2, 2, :), 1, [])), freqs(2)-freqs(1))];
end