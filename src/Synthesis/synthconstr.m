function [c, ceq] = synthconstr(x, sz)
    G = casctran(x, sz);
    W1 = [0, -sqrt(2)/2; -sqrt(2)/2, 0; 0, sqrt(2)/2; sqrt(2)/2, 0];
    W2 = flip(-W1);
    H = tsc(G, sz);
    H = [H; eye(2)];
    c = norm((W1'*H)/(W2'*H), Inf) - 1;
    ceq = [];
end