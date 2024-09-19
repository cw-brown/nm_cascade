function gamma = topology(sz)
    %% Creates the sparse Topolgy Matrix Gamma for the cascade network.
    ports = fpg(sz);
    nnets = sz(1)*sz(2)+2;
    v = zeros(1, sum(ports));
    i = zeros(1, sum(ports));
    j = zeros(1, sum(ports));
    %% Entrance Network
    a = 1;
    jstart = sum(ports(1:sz(3))) + 1;
    jcols = v(jstart:jstart+ports(sz(3)));
    jzerocol = find(jcols == 0);
    i(a) = 1; j(a) = jstart+jzerocol(1)-1;
    v(1) = 1; v(jstart+jzerocol(1)-1) = 1;
    a = a + 1;
    for k = 2:nnets-1
        if mod(k, sz(1)) ~= 1
            %% Row Phase
            istart = sum(ports(1:k-1)) + 1;
            irows = v(istart:istart+ports(k)-1);
            izerorow = find(irows == 0);
            jstart = sum(ports(1:k)) + 1;
            jcols = v(jstart:jstart+ports(k+1)-1);
            jzerocol = find(jcols == 0);
            if isempty(jzerocol) || isempty(izerorow); continue; end
            i(a) = istart+izerorow(1)-1; j(a) = jstart+jzerocol(1)-1;
            v(istart+izerorow(1)-1) = 1; v(jstart+jzerocol(1)-1) = 1;
            a = a + 1;
        end
        if k < (sz(2)-1)*sz(1)+2
            %% Column Phase
            istart = sum(ports(1:k-1)) + 1;
            irows = v(istart:istart+ports(k)-1);
            izerorow = find(irows == 0);
            jstart = sum(ports(1:k+sz(1)-1)) + 1;
            jcols = v(jstart:jstart+ports(k+sz(1))-1);
            jzerocol = find(jcols == 0);
            if isempty(jzerocol) || isempty(izerorow); continue; end
            i(a) = istart+izerorow(1)-1; j(a) = jstart+jzerocol(1)-1;
            v(istart+izerorow(1)-1) = 1; v(jstart+jzerocol(1)-1) = 1;
            a = a + 1;
        end
    end
    %% Exit Network
    istart = sum(ports(1:nnets-1)) + 1;
    irows = v(istart:istart+ports(end)-1);
    izerorow = find(irows == 0);
    jstart = sum(ports(1:sz(4))) + 1;
    jcols = v(jstart:jstart+ports(sz(4)));
    jzerocol = find(jcols == 0);
    i(a) = istart+izerorow(1)-1; j(a) = jstart+jzerocol(1)-1;
    v(istart+izerorow(1)-1) = 1; v(jstart+jzerocol(1)-1) = 1;
    i(sum(ports)/2+1:end) = j(1:sum(ports)/2);
    j(sum(ports)/2+1:end) = i(1:sum(ports)/2);
    gamma = sparse(i, j, v, sum(ports), sum(ports), sum(ports));
end