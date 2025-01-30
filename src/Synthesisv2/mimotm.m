function g = mimotm(x, sz)
    nt = (sz^2 + sz)/2;
    g = tf(1, 1);
    i = meshgrid(1:sz, 1:sz);
    ip = triu(i); ig = triu(i');
    ip = nonzeros(ip); ig = nonzeros(ig);
    nf = 5;
    for ii = 1:nt
        gain = x((ii-1)*nf+1);
        % zeros = [-abs(x((ii-1)*nf+2))+x((ii-1)*nf+3)*1j, -abs(x((ii-1)*nf+2))-x((ii-1)*nf+3)*1j, ...
        %          -abs(x((ii-1)*nf+4))];
        zeros = -abs(x((ii-1)*nf+2));
        poles = [-abs(x((ii-1)*nf+3))+x((ii-1)*nf+4)*1j, -abs(x((ii-1)*nf+3))-x((ii-1)*nf+4)*1j, ...
                 -abs(x((ii-1)*nf+5))];
        g(ip(ii), ig(ii)) = zpk(zeros, poles, gain);
        g(ig(ii), ip(ii)) = g(ip(ii), ig(ii));
    end
end