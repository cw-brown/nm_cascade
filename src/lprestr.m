function [c, ceq] = lprestr(x, freqs, sz)
    %% Restrictions to make the network lossless and passive
    c = [];
    s_params = num2sparam(x, freqs, sz);
    nfreq = length(freqs);

    st = 1;
    for ii = 1:length(s_params)
        net = s_params{ii};
        N = size(net, 1);
        for ff = 1:nfreq
            lossless = sum(abs(net(:, :, ff)).^2, 1) - 1;
            passive = norm(net(:, :, ff), 2) - 1;
            ceq(st:st+N) = [lossless, passive];
            st = st+N+1;
        end
    end
end