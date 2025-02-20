function gsys = casctran(x, sz)
    % Return a cell array of MIMO systems formed from x values
    networks = fpg(sz);
    gsys = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 8*(networks(ii)^2+networks(ii))/2;
        gsys{ii} = mimotm(x(st:st+nvar-1), networks(ii));
        st = st + nvar;
    end

    function g = mimotm(x, sz)
        s = tf('s');
        nt = (sz^2 + sz)/2;
        g = tf(1, 1);
        i = meshgrid(1:sz, 1:sz);
        ip = triu(i); ig = triu(i');
        ip = nonzeros(ip); ig = nonzeros(ig);
        nf = 8;
        for jj = 1:nt
            % gain = x((jj-1)*nf+1);
            % zeros = x((jj-1)*nf+2);
            % poles = -abs(x((jj-1)*nf+3));
            % g(ip(jj), ig(jj)) = zpk(zeros, poles, gain);
            % g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
            g(ip(jj), ig(jj)) = x((jj-1)*nf+1)/(s+x((jj-1)*nf+2)) + ...
                                x((jj-1)*nf+3)/(s+x((jj-1)*nf+4)) + ...
                                x((jj-1)*nf+5)/(s+x((jj-1)*nf+6)) + ...
                                x((jj-1)*nf+7)/(s+x((jj-1)*nf+8));
            g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
        end
    end
end