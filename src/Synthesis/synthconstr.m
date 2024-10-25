function [c, ceq] = synthconstr(x, sz)
    G = casctran(x, sz);
    n = length(G);
    ceq = [];
    c = zeros(1, 2*n);
    for ii = 1:n
        g = G{ii};
        [nu, ny] = iosize(g);
        H = [g; eye(nu)];
        %% Passivity
        Q = [zeros(nu), -eye(nu); -eye(ny), zeros(ny)];
        [W1, W2] = getQData(Q);
        c((ii-1)*n+1) = norm((W1'*H)/(W2'*H), Inf) - (1-eps^2);
        %% Gain<1
        Q = [eye(nu), zeros(nu); zeros(ny), -(0.95)^2*eye(ny)];
        [W1, W2] = getQData(Q);
        c((ii-1)*n+2) = norm((W1'*H)/(W2'*H), Inf) - (1-eps^2);
    end

    function [W1, W2] = getQData(Q)
        [U, D] = schur(Q);
        D = diag(D);
        L1 = find(D>=0);
        L2 = find(D<0);
        W1 = lrscale(U(:, L1), [], sqrt(D(L1)));
        W2 = lrscale(U(:, L2), [], sqrt(D(L2)));
    end
end