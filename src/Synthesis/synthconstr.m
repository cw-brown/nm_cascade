function [c, ceq] = synthconstr(x, sz)
    networks = fpg(sz);
    c = zeros(length(networks), 1);
    st = 1;
    for ii = 1:length(networks)
        nvar = 13*(networks(ii)^2+networks(ii))/2;
        g = mimotm(x(st:st+nvar-1), networks(ii));
        st = st + nvar;
        c(ii) = norm(g) - 1;
    end
    ceq = [];
end