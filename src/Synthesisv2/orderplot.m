clear; clc; close all;
sz = [1, 3, 1, 3];
networks = fpg(sz);
nvar = 3*sum(networks.^2+networks)/2;

% Move through grids up to20x20
k = 10;
j = 10;
[x,y] = meshgrid(1:k,1:j);
eval = zeros(k, j);
figure;
for m = 1:k
    parfor n = 1:j
        sz = [m,n,1,m*n];
        networks = fpg(sz);
        nvar = 3*sum(networks.^2+networks)/2;
        xt = ones(1,nvar);
        G = tranmake(xt,sz);
        H = tsc(G,sz);
        eval(m,n) = order(H);
        
    end
    surf(x,y,eval); drawnow;
end


function gsys = tranmake(x, sz)
    % Return a cell array of MIMO systems formed from x values
    networks = fpg(sz);
    gsys = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 3*(networks(ii)^2+networks(ii))/2;
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
        nf = 3;
        for jj = 1:nt
            g(ip(jj), ig(jj)) = x((jj-1)*nf+1) + ...
                x((jj-1)*nf+2)/(s+abs(x((jj-1)*nf+3)));
            g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
        end
    end
end