function gsys = casctran(x, sz)
    % Return a cell array of MIMO systems formed from x values
    networks = fpg(sz);
    gsys = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 2*(networks(ii)^2+networks(ii))/2;
        % nvar = 4;
        gsys{ii} = mimotm(x(st:st+nvar-1), networks(ii));
        st = st + nvar;
    end

    function g = mimotm(x, sz)
        s = tf('s');
        nt = (sz^2 + sz)/2;
        % nt = 2;
        g = tf(1, 1);
        i = meshgrid(1:sz, 1:sz);
        ip = triu(i); ig = triu(i');
        ip = nonzeros(ip); ig = nonzeros(ig);
        nf = 2;
        for jj = 1:nt
            % gain = x((jj-1)*nf+1);
            % zeros = x((jj-1)*nf+2);
            % poles = -abs(x((jj-1)*nf+3));
            % g(ip(jj), ig(jj)) = zpk(zeros, poles, gain);
            % g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
            % g(ip(jj), ig(jj)) = (x((jj-1)*nf+1) + 1j*x((jj-1)*nf+2))/(s-(abs(x((jj-1)*nf+3)) + 1j*x((jj-1)*nf+4))) + ...
            %     (x((jj-1)*nf+1) - 1j*x((jj-1)*nf+2))/(s-(abs(x((jj-1)*nf+3)) - 1j*x((jj-1)*nf+4))) + ...
            %     x((jj-1)*nf+5);
            % g(ip(jj), ig(jj)) = x((jj-1)*nf+1)/(s-abs(x((jj-1)*nf+2))) + x((jj-1)*nf+3);
            % g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
            g(ip(jj), ig(jj)) = x((jj-1)*nf+1)/(s-abs(x((jj-1)*nf+1)));
            g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
        end
        g(2,2) = g(1,1);
        g(2,1) = g(1,2);
        g(1,2) = 0;
        g(2,1) = 0;
    end
end