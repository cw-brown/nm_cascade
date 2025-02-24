function [c, ceq] = synconstr(x, sz)
    G = casctran(x, sz);
    n = length(G);
    ceq = zeros(n, 1);
    c = zeros(n, 1);
    for ii = 1:n
        c(ii) = getPeakGain(G{ii}) - (1-eps^2);
    end
end