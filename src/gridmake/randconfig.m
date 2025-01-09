function c = randconfig(imax)
    % Overcomes randi problems
    c = uint64(rand() * imax);
end