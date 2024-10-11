function ports = fpg(sz)
    %% Fast port generation algorithm
    ports = reshape(conv2(ones(sz(1), sz(2)), [0 1 0; 1 0 1; 0 1 0], "same"), 1, []);
    ports(sz(3)) = ports(sz(3)) + 1; ports(sz(4)) = ports(sz(4)) + 1;
end