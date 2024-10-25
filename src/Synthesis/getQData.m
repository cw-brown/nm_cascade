function [W1, W2] = getQData(Q)
    [U, D] = schur(Q);
    D = diag(D);
    L1 = find(D>=0);
    L2 = find(D<0);
    W1 = lrscale(U(:, L1), [], sqrt(D(L1)));
    W2 = lrscale(U(:, L2), [], sqrt(D(L2)));
end