function Z = cauer1(n)
    % Returns the Cauer 1 Form transfer function for Z(s)
    n = flip(n);
    for ii = 1:length(n)
        if ii == 1
            Z = 1/n(ii);
        elseif ii == length(n)
            Z = n(ii) + Z;
        else
            Z = 1/(n(ii) + Z);
        end
    end
end