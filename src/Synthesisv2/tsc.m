function H = tsc(G, sz)
    % Math based on reference from "Computer-Aided Design of Microwave Circuits" by K.C. Gupta
    
    arguments 
        G cell
        sz (1, 4) double {mustBeNonnegative, mustBeInteger}
    end

    port = fpg(sz);
    gamma = topology(sz);
    c_1 = zeros(sum(port)+2, 1); c_1(1) = 1;
    c_2 = zeros(sum(port)+2, 1); c_2(end) = 1;

    for ii = 1:sz(1)*sz(2)
        if ii == 1
            S = blkdiag(0, G{ii});
        else
            S = blkdiag(S, G{ii});
        end
    end
    S = blkdiag(S, 0);

    W = gamma - S;
    a_1 = W\c_1;
    a_2 = W\c_2;
    b_1 = gamma*a_1;
    b_2 = gamma*a_2;

    H = [a_1(1)/b_1(1), a_2(1)/b_2(end); a_1(end)/b_1(1), a_2(end)/b_2(end)];

    function gamma = topology(sz)
        %% Creates the sparse Topolgy Matrix Gamma for the cascade network.
        ports = fpg(sz); ports = [1 ports 1];
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
        if ~isempty(jzerocol) || ~isempty(izerorow)
            i(a) = istart+izerorow(1)-1; j(a) = jstart+jzerocol(1)-1;
            v(istart+izerorow(1)-1) = 1; v(jstart+jzerocol(1)-1) = 1;
        end
        i(sum(ports)/2+1:end) = j(1:sum(ports)/2);
        j(sum(ports)/2+1:end) = i(1:sum(ports)/2);
        gamma = sparse(i, j, v, sum(ports), sum(ports), sum(ports));
    end
end