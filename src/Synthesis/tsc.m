function H = tsc(G, sz)
    % Math based on reference from "Computer-Aided Design of Microwave Circuits" by K.C. Gupta
    
    arguments 
        G cell
        sz (1, 4) uint16 {mustBeNonnegative, mustBeVector}
    end

    ports = fpg(sz);
    gamma = topology(sz);
    c_1 = zeros(sum(ports)+2, 1); c_1(1) = 1;
    c_2 = zeros(sum(ports)+2, 1); c_2(end) = 1;

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
end