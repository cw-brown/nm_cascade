function g = mimotm(x, sz)
    nt = (sz^2 + sz)/2;
    g = tf(1, 1);
    nf = 8;
    i = meshgrid(1:sz, 1:sz);
    ip = triu(i); ig = triu(i');
    ip = nonzeros(ip); ig = nonzeros(ig);
    for ii = 1:nt
        gain = x((ii-1)*nf+1);
        zeros = [x((ii-1)*nf+2)+x((ii-1)*nf+3)*1j, x((ii-1)*nf+2)-x((ii-1)*nf+3)*1j, ...
                 x((ii-1)*nf+3)+x((ii-1)*nf+4)*1j, x((ii-1)*nf+3)-x((ii-1)*nf+4)*1j, ...
                 x((ii-1)*nf+5), x((ii-1)*nf+6)];
        poles = [-abs(x((ii-1)*nf+7))+x((ii-1)*nf+8)*1j, -abs(x((ii-1)*nf+7))-x((ii-1)*nf+8)*1j, ...
                 -abs(x((ii-1)*nf+9))+x((ii-1)*nf+10)*1j, -abs(x((ii-1)*nf+9))-x((ii-1)*nf+10)*1j, ...
                 -abs(x((ii-1)*nf+11))+x((ii-1)*nf+12)*1j, -abs(x((ii-1)*nf+11))-x((ii-1)*nf+12)*1j, ...
                 -abs(x((ii-1)*nf+13))];
        g(ip(ii), ig(ii)) = zpk(zeros, poles, gain);
        g(ig(ii), ip(ii)) = g(ip(ii), ig(ii));
    end
end