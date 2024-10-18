function g = mimotm(x, sz)
    nt = (sz^2 + sz)/2;
    g = tf(1, 1);
    nf = 7;
    i = meshgrid(1:sz, 1:sz);
    ip = triu(i); ig = triu(i');
    ip = nonzeros(ip); ig = nonzeros(ig);
    for ii = 1:nt
        gain = abs(x((ii-1)*nf+1));
        zeros = [x((ii-1)*nf+2)+x((ii-1)*nf+3)*1j, x((ii-1)*nf+2)-x((ii-1)*nf+3)*1j, ...
                 x((ii-1)*nf+4)];
        poles = [-abs(x((ii-1)*nf+5))+x((ii-1)*nf+6)*1j, -abs(x((ii-1)*nf+5))-x((ii-1)*nf+6)*1j, ...
                 -abs(x((ii-1)*nf+7))];
        g(ip(ii), ig(ii)) = zpk(zeros, poles, gain);
        g(ig(ii), ip(ii)) = g(ip(ii), ig(ii));
    end
end